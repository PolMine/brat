HTMLWidgets.widget({

  name: "brat",
  
  type: "output",
  
  factory: function(el, width, height) {
    
    var annodata; // define here to make it available globally
    var dispatcher; // define here to make it available globally
    
    // still necessary? loading fonts is suppressed
    var webFontURLs = [
      './static/fonts/Astloch-Bold.ttf',
      './static/fonts/PT_Sans-Caption-Web-Regular.ttf',
      './static/fonts/Liberation_Sans-Regular.ttf'
    ];
    
    // BEGIN variables defined in AnnotatorUI / annotator_ui.js
    // only those variables are defined here that are actually used
    var arcDragJustStarted = false;
    var arcDragOrigin = null;
    var data = null;
    var reselectedSpan = null;
    var lockOptions = null;
    var spanForm = $('#span_form');
    var rapidSpanForm = $('#rapid_span_form');
    var spanKeymap = null;
    // END


    
    var rememberData = function(_data) {
      if (_data && !_data.exception) {
        data = _data;
      }
    };

    var tryToAnnotate = function(evt) {
        var sel = window.getSelection();
        var theFocusNode = sel.focusNode;
        if (!theFocusNode) return;

        var chunkIndexFrom = sel.anchorNode && $(sel.anchorNode.parentNode).attr('data-chunk-id');
        var chunkIndexTo;
        chunkIndexTo = $(theFocusNode.parentNode).attr('data-chunk-id');
        if (!chunkIndexTo) {
          theFocusNode = $(theFocusNode).children()[0].firstChild;
          chunkIndexTo = $(theFocusNode.parentNode).attr('data-chunk-id');
        }
        // var chunkIndexTo = sel.focusNode && ($(sel.focusNode.parentNode).attr('data-chunk-id') || $(sel.focusNode).children().first().attr('data-chunk-id'));

        // fallback for firefox (at least):
        // it's unclear why, but for firefox the anchor and focus
        // node parents are always undefined, the the anchor and
        // focus nodes themselves do (often) have the necessary
        // chunk ID. However, anchor offsets are almost always
        // wrong, so we'll just make a guess at what the user might
        // be interested in tagging instead of using what's given.
        var anchorOffset = null;
        var focusOffset = null;
        if (chunkIndexFrom === undefined && chunkIndexTo === undefined &&
            $(sel.anchorNode).attr('data-chunk-id') &&
            $(theFocusNode).attr('data-chunk-id')) {
          // A. Scerri FireFox chunk

          var range = sel.getRangeAt(0);
          var svgOffset = $(svg._svg).offset();
          var flip = false;
          var tries = 0;
          while (tries < 2) {
            var sp = svg._svg.createSVGPoint();
            sp.x = (flip ? evt.pageX : dragStartedAt.pageX) - svgOffset.left;
            sp.y = (flip ? evt.pageY : dragStartedAt.pageY) - (svgOffset.top + 8);
            var startsAt = range.startContainer;
            anchorOffset = startsAt.getCharNumAtPosition(sp);
            chunkIndexFrom = startsAt && $(startsAt).attr('data-chunk-id');
            if (anchorOffset != -1) {
              break;
            }
            flip = true;
            tries++;
          }
          sp.x = (flip ? dragStartedAt.pageX : evt.pageX) - svgOffset.left;
          sp.y = (flip ? dragStartedAt.pageY : evt.pageY) - (svgOffset.top + 8);
          var endsAt = range.endContainer;
          focusOffset = endsAt.getCharNumAtPosition(sp);

          if (range.startContainer == range.endContainer && anchorOffset > focusOffset) {
            var t = anchorOffset;
            anchorOffset = focusOffset;
            focusOffset = t;
            flip = false;
          }
          if (focusOffset != -1) {
            focusOffset++;
          }
          chunkIndexTo = endsAt && $(endsAt).attr('data-chunk-id');

          //console.log('fallback from', data.chunks[chunkIndexFrom], anchorOffset);
          //console.log('fallback to', data.chunks[chunkIndexTo], focusOffset);
        } else {
          // normal case, assume the exact offsets are usable
          anchorOffset = sel.anchorOffset;
          focusOffset = sel.focusOffset;
        }
        
        if (evt.type == 'keydown') {
          var offset = sel.focusOffset;
          if (offset >= theFocusNode.length) {
            offset = theFocusNode.length - 1;
          }
          var endpos = theFocusNode.parentNode.getEndPositionOfChar(offset);
          var svgpos = $(svg._svg).offset();
          evt.clientX = endpos.x + svgpos.left - window.scrollX;
          evt.clientY = endpos.y + svgpos.top - window.scrollY;
        }

        if (chunkIndexFrom !== undefined && chunkIndexTo !== undefined) {
          var chunkFrom = data.chunks[chunkIndexFrom];
          var chunkTo = data.chunks[chunkIndexTo];
          if (chunkFrom.text.correctOffset) {
            anchorOffset = chunkFrom.text.correctOffset(anchorOffset);
          }
          if (chunkTo.text.correctOffset) {
            focusOffset = chunkTo.text.correctOffset(focusOffset);
          }
          var selectedFrom = chunkFrom.from + anchorOffset;
          var selectedTo = chunkTo.from + focusOffset;
          sel.removeAllRanges();

          if (selectedFrom > selectedTo) {
            var tmp = selectedFrom; selectedFrom = selectedTo; selectedTo = tmp;
          }
          // trim
          while (selectedFrom < selectedTo && " \n\t".indexOf(data.text.substr(selectedFrom, 1)) !== -1) selectedFrom++;
          while (selectedFrom < selectedTo && " \n\t".indexOf(data.text.substr(selectedTo - 1, 1)) !== -1) selectedTo--;

          // shift+click allows zero-width spans
          if (selectedFrom === selectedTo && !evt.shiftKey) {
            // simple click (zero-width span)
            return;
          }

          var newOffset = [selectedFrom, selectedTo];
          
          // BEGIN Modification by Andreas Blaette
          annodata.docData.entities.push(['T9', 'Person', [[selectedFrom, selectedTo]]]);
          dispatcher.post('requestRenderData', [annodata.docData]);
          // END Modification by Andreas Blaette
          
          if (reselectedSpan) {
            var newOffsets = reselectedSpan.offsets.slice(0); // clone
            spanOptions.old_offsets = JSON.stringify(reselectedSpan.offsets);
            if (selectedFragment !== null) {
              if (selectedFragment !== false) {
                newOffsets.splice(selectedFragment, 1);
              }
              newOffsets.push(newOffset);
              newOffsets.sort(Util.cmpArrayOnFirstElement);
              spanOptions.offsets = newOffsets;
            } else {
              spanOptions.offsets = [newOffset];
            }
          } else {
            spanOptions = {
              action: 'createSpan',
              offsets: [newOffset]
            }
          }


/* In relation to #786, removed the cross-sentence checking code
          var crossSentence = true;
          $.each(sourceData.sentence_offsets, function(sentNo, startEnd) {
            if (selectedTo <= startEnd[1]) {
              // this is the sentence

              if (selectedFrom >= startEnd[0]) {
                crossSentence = false;
              }
              return false;
            }
          });

          if (crossSentence) {
            // attempt to annotate across sentence boundaries; not supported
            dispatcher.post('messages', [[['Error: cannot annotate across a sentence break', 'error']]]);
            if (reselectedSpan) {
              $(reselectedSpan.rect).removeClass('reselect');
            }
            reselectedSpan = null;
            svgElement.removeClass('reselect');
          } else
*/
          if (lockOptions) {
            spanFormSubmit();
            dispatcher.post('logAction', ['spanLockNewSubmitted']);
          } else if (!Configuration.rapidModeOn || reselectedSpan != null) {
            // normal span select in standard annotation mode
            // or reselect: show selector
            var spanText = data.text.substring(selectedFrom, selectedTo);
            /* fillSpanTypesAndDisplayForm(evt, spanText, reselectedSpan); */
            // for precise timing, log annotation display to user.
            dispatcher.post('logAction', ['spanSelected']);
          } else {
            // normal span select in rapid annotation mode: call
            // server for span type candidates
            var spanText = data.text.substring(selectedFrom, selectedTo);
            // TODO: we're currently storing the event to position the
            // span form using adjustToCursor() (which takes an event),
            // but this is clumsy and suboptimal (user may have scrolled
            // during the ajax invocation); think of a better way.
            lastRapidAnnotationEvent = evt;

            dispatcher.post('ajax', [ { 
                            action: 'suggestSpanTypes',
                            collection: coll,
                            'document': doc,
                            start: selectedFrom,
                            end: selectedTo,
                            text: spanText,
                            model: $('#rapid_model').val(),
                            }, 'suggestedSpanTypes']);
          }
        }
      };
    
      var onMouseDown = function(evt) {
        dragStartedAt = evt; // XXX do we really need the whole evt?
        if (/*!that.user || */ arcDragOrigin) return;
        var target = $(evt.target);
        var id;
        // is it arc drag start?
        if (id = target.attr('data-span-id')) {
          arcOptions = null;
          startArcDrag(id);
          evt.stopPropagation();
          evt.preventDefault();
          return false;
        }
      };
      
      var onMouseMove = function(evt) {
        if (arcDragOrigin) {
          if (arcDragJustStarted) {
            arcDragArc.setAttribute('visibility', 'visible');
            // show the possible targets
            var span = data.spans[arcDragOrigin] || {};
            var spanDesc = spanTypes[span.type] || {};

            // separate out possible numeric suffix from type for highight
            // (instead of e.g. "Theme3", need to look for "Theme")
            var noNumArcType = stripNumericSuffix(arcOptions && arcOptions.type);
            var targetTypes = [];
            $.each(spanDesc.arcs || [], function(possibleArcNo, possibleArc) {
              if ((arcOptions && possibleArc.type == noNumArcType) || !(arcOptions && arcOptions.old_target)) {
                $.each(possibleArc.targets || [], function(possibleTargetNo, possibleTarget) {
                  targetTypes.push(possibleTarget);
                });
              }
            });
            arcTargets = [];
            arcTargetRects = [];
            $.each(data.spans, function(spanNo, span) {
              if (span.id == arcDragOrigin) return;
              if (targetTypes.indexOf(span.type) != -1) {
                arcTargets.push(span.id);
                $.each(span.fragments, function(fragmentNo, fragment) {
                  arcTargetRects.push(fragment.rect);
                });
              }
            });
            $(arcTargetRects).addClass('reselectTarget');
          }
          clearSelection();
          var mx = evt.pageX - svgPosition.left;
          var my = evt.pageY - svgPosition.top + 5; // TODO FIXME why +5?!?
          var y = Math.min(arcDragOriginBox.y, my) - draggedArcHeight;
          var dx = (arcDragOriginBox.center - mx) / 4;
          var path = svg.createPath().
            move(arcDragOriginBox.center, arcDragOriginBox.y).
            curveC(arcDragOriginBox.center - dx, y,
                mx + dx, y,
                mx, my);
          arcDragArc.setAttribute('d', path.path());
        } else {
          // A. Scerri FireFox chunk

          // if not, then is it span selection? (ctrl key cancels)
          var sel = window.getSelection();
          var chunkIndexFrom = sel.anchorNode && $(sel.anchorNode.parentNode).attr('data-chunk-id');
          var chunkIndexTo = sel.focusNode && $(sel.focusNode.parentNode).attr('data-chunk-id');
          // fallback for firefox (at least):
          // it's unclear why, but for firefox the anchor and focus
          // node parents are always undefined, the the anchor and
          // focus nodes themselves do (often) have the necessary
          // chunk ID. However, anchor offsets are almost always
          // wrong, so we'll just make a guess at what the user might
          // be interested in tagging instead of using what's given.
          var anchorOffset = null;
          var focusOffset = null;
          if (chunkIndexFrom === undefined && chunkIndexTo === undefined &&
              $(sel.anchorNode).attr('data-chunk-id') &&
              $(sel.focusNode).attr('data-chunk-id')) {
            // Lets take the actual selection range and work with that
            // Note for visual line up and more accurate positions a vertical offset of 8 and horizontal of 2 has been used!
            var range = sel.getRangeAt(0);
            var svgOffset = $(svg._svg).offset();
            var flip = false;
            var tries = 0;
            // First try and match the start offset with a position, if not try it against the other end
            while (tries < 2) {
              var sp = svg._svg.createSVGPoint();
              sp.x = (flip ? evt.pageX : dragStartedAt.pageX) - svgOffset.left;
              sp.y = (flip ? evt.pageY : dragStartedAt.pageY) - (svgOffset.top + 8);
              var startsAt = range.startContainer;
              anchorOffset = startsAt.getCharNumAtPosition(sp);
              chunkIndexFrom = startsAt && $(startsAt).attr('data-chunk-id');
              if (anchorOffset != -1) {
                break;
              }
              flip = true;
              tries++;
            }

            // Now grab the end offset
            sp.x = (flip ? dragStartedAt.pageX : evt.pageX) - svgOffset.left;
            sp.y = (flip ? dragStartedAt.pageY : evt.pageY) - (svgOffset.top + 8);
            var endsAt = range.endContainer;
            focusOffset = endsAt.getCharNumAtPosition(sp);

            // If we cannot get a start and end offset stop here
            if (anchorOffset == -1 || focusOffset == -1) {
              return;
            }
            // If we are in the same container it does the selection back to front when dragged right to left, across different containers the start is the start and the end if the end!
            if(range.startContainer == range.endContainer && anchorOffset > focusOffset) {
              var t = anchorOffset;
              anchorOffset = focusOffset;
              focusOffset = t;
              flip = false;
            }
            chunkIndexTo = endsAt && $(endsAt).attr('data-chunk-id');

            // Now take the start and end character rectangles
            startRec = startsAt.getExtentOfChar(anchorOffset);
            startRec.y += 2;
            endRec = endsAt.getExtentOfChar(focusOffset);
            endRec.y += 2;

            // If nothing has changed then stop here
            if (lastStartRec != null && lastStartRec.x == startRec.x && lastStartRec.y == startRec.y && lastEndRec != null && lastEndRec.x == endRec.x && lastEndRec.y == endRec.y) {
              return;
            }

            if (selRect == null) {
              var rx = startRec.x;
              var ry = startRec.y;
              var rw = (endRec.x + endRec.width) - startRec.x;
              if (rw < 0) {
                rx += rw;
                rw = -rw;
              }
              var rh = Math.max(startRec.height, endRec.height);

              selRect = new Array();
              var activeSelRect = makeSelRect(rx, ry, rw, rh);
              selRect.push(activeSelRect);
              startsAt.parentNode.parentNode.parentNode.insertBefore(activeSelRect, startsAt.parentNode.parentNode);
            } else {
              if (startRec.x != lastStartRec.x && endRec.x != lastEndRec.x && (startRec.y != lastStartRec.y || endRec.y != lastEndRec.y)) {
                if (startRec.y < lastStartRec.y) {
                  selRect[0].setAttributeNS(null, "width", lastStartRec.width);
                  lastEndRec = lastStartRec;
                } else if (endRec.y > lastEndRec.y) {
                  selRect[selRect.length - 1].setAttributeNS(null, "x",
                      parseFloat(selRect[selRect.length - 1].getAttributeNS(null, "x"))
                      + parseFloat(selRect[selRect.length - 1].getAttributeNS(null, "width"))
                      - lastEndRec.width);
                  selRect[selRect.length - 1].setAttributeNS(null, "width", 0);
                  lastStartRec=lastEndRec;
                }
              }

              // Start has moved
              var flip = !(startRec.x == lastStartRec.x && startRec.y == lastStartRec.y);
              // If the height of the start or end changed we need to check whether
              // to remove multi line highlights no longer needed if the user went back towards their start line
              // and whether to create new ones if we moved to a newline
              if (((endRec.y != lastEndRec.y)) || ((startRec.y != lastStartRec.y))) {
                // First check if we have to remove the first highlights because we are moving towards the end on a different line
                var ss = 0;
                for (; ss != selRect.length; ss++) {
                  if (startRec.y <= parseFloat(selRect[ss].getAttributeNS(null, "y"))) {
                    break;
                  }
                }
                // Next check for any end highlights if we are moving towards the start on a different line
                var es = selRect.length - 1;
                for (; es != -1; es--) {
                  if (endRec.y >= parseFloat(selRect[es].getAttributeNS(null, "y"))) {
                    break;
                  }
                }
                // TODO put this in loops above, for efficiency the array slicing could be done separate still in single call
                var trunc = false;
                if (ss < selRect.length) {
                  for (var s2 = 0; s2 != ss; s2++) {
                    selRect[s2].parentNode.removeChild(selRect[s2]);
                    es--;
                    trunc = true;
                  }
                  selRect = selRect.slice(ss);
                }
                if (es > -1) {
                  for (var s2 = selRect.length - 1; s2 != es; s2--) {
                    selRect[s2].parentNode.removeChild(selRect[s2]);
                    trunc = true;
                  }
                  selRect = selRect.slice(0, es + 1);
                }

                // If we have truncated the highlights we need to readjust the last one
                if (trunc) {
                  var activeSelRect = flip ? selRect[0] : selRect[selRect.length - 1];
                  if (flip) {
                    var rw = 0;
                    if (startRec.y == endRec.y) {
                      rw = (endRec.x + endRec.width) - startRec.x;
                    } else {
                      rw = (parseFloat(activeSelRect.getAttributeNS(null, "x"))
                          + parseFloat(activeSelRect.getAttributeNS(null, "width")))
                          - startRec.x;
                    }
                    activeSelRect.setAttributeNS(null, "x", startRec.x);
                    activeSelRect.setAttributeNS(null, "y", startRec.y);
                    activeSelRect.setAttributeNS(null, "width", rw);
                  } else {
                    var rw = (endRec.x + endRec.width) - parseFloat(activeSelRect.getAttributeNS(null, "x"));
                    activeSelRect.setAttributeNS(null, "width", rw);
                  }
                } else {
                  // We didnt truncate anything but we have moved to a new line so we need to create a new highlight
                  var lastSel = flip ? selRect[0] : selRect[selRect.length - 1];
                  var startBox = startsAt.parentNode.getBBox();
                  var endBox = endsAt.parentNode.getBBox();

                  if (flip) {
                    lastSel.setAttributeNS(null, "width",
                        (parseFloat(lastSel.getAttributeNS(null, "x"))
                        + parseFloat(lastSel.getAttributeNS(null, "width")))
                        - endBox.x);
                    lastSel.setAttributeNS(null, "x", endBox.x);
                  } else {
                    lastSel.setAttributeNS(null, "width",
                        (startBox.x + startBox.width)
                        - parseFloat(lastSel.getAttributeNS(null, "x")));
                  }
                  var rx = 0;
                  var ry = 0;
                  var rw = 0;
                  var rh = 0;
                  if (flip) {
                    rx = startRec.x;
                    ry = startRec.y;
                    rw = $(svg._svg).width() - startRec.x;
                    rh = startRec.height;
                  } else {
                    rx = endBox.x;
                    ry = endRec.y;
                    rw = (endRec.x + endRec.width) - endBox.x;
                    rh = endRec.height;
                  }
                  var newRect = makeSelRect(rx, ry, rw, rh);
                  if (flip) {
                    selRect.unshift(newRect);
                  } else {
                    selRect.push(newRect);
                  }

                  // Place new highlight in appropriate slot in SVG graph
                  startsAt.parentNode.parentNode.parentNode.insertBefore(newRect, startsAt.parentNode.parentNode);
                }
              } else {
                // The user simply moved left or right along the same line so just adjust the current highlight
                var activeSelRect = flip ? selRect[0] : selRect[selRect.length - 1];
                // If the start moved shift the highlight and adjust width
                if (flip) {
                  var rw = (parseFloat(activeSelRect.getAttributeNS(null, "x"))
                      + parseFloat(activeSelRect.getAttributeNS(null, "width")))
                      - startRec.x;
                  activeSelRect.setAttributeNS(null, "x", startRec.x);
                  activeSelRect.setAttributeNS(null, "y", startRec.y);
                  activeSelRect.setAttributeNS(null, "width", rw);
                } else {
                  // If the end moved then simple change the width
                  var rw = (endRec.x + endRec.width)
                      - parseFloat(activeSelRect.getAttributeNS(null, "x"));
                  activeSelRect.setAttributeNS(null, "width", rw);
                }
              }
            }
            lastStartRec = startRec;
            lastEndRec = endRec;
          }
        }
        arcDragJustStarted = false;
      };

    
    var onMouseUp = function(evt) {
        // CHANGED: Following line commented out
        // if (that.user === null) return;

        var target = $(evt.target);

        // three things that are clickable in SVG
        var targetSpanId = target.data('span-id');
        var targetChunkId = target.data('chunk-id');
        var targetArcRole = target.data('arc-role');
        
        if (!(targetSpanId !== undefined || targetChunkId !== undefined || targetArcRole !== undefined)) {
          // misclick
          clearSelection();
          stopArcDrag(target);
          return;
        }

        if (arcDragJustStarted && (Util.isMac ? evt.metaKey : evt.ctrlKey)) {
          // is it arc drag start (with ctrl or alt)? do nothing special

        } else if (arcDragOrigin) {
          // is it arc drag end?
          var origin = arcDragOrigin;
          var id = target.attr('data-span-id');
          var targetValid = arcTargets.indexOf(id) != -1;
          stopArcDrag(target);
          if (id && origin != id && targetValid) {
            var originSpan = data.spans[origin];
            var targetSpan = data.spans[id];
            if (arcOptions && arcOptions.old_target) {
              arcOptions.target = targetSpan.id;
              dispatcher.post('ajax', [arcOptions, 'edited']);
            } else {
              arcOptions = {
                action: 'createArc',
                origin: originSpan.id,
                target: targetSpan.id,
                collection: coll,
                'document': doc
              };
              $('#arc_origin').text(Util.spanDisplayForm(spanTypes, originSpan.type)+' ("'+originSpan.text+'")');
              $('#arc_target').text(Util.spanDisplayForm(spanTypes, targetSpan.type)+' ("'+targetSpan.text+'")');
              fillArcTypesAndDisplayForm(evt, originSpan.type, targetSpan.type);
              // for precise timing, log dialog display to user.
              dispatcher.post('logAction', ['arcSelected']);
            }
          }
        } else if (!(Util.isMac ? evt.metaKey : evt.ctrlKey)) {
          // if not, then is it span selection? (ctrl key cancels)
          tryToAnnotate(evt);
        }
      };
    
    return {
      renderValue: function(x) {
        
        annodata = x; // make it available globally
        
        // BEGIN adapted from Util.embed() in util.js 
        
        dispatcher = new Dispatcher();
        var visualizer = new Visualizer(dispatcher, el.id, webFontURLs);
        
        annodata.docData.collection = null;
        dispatcher.post('collectionLoaded', [annodata.collData]);
        dispatcher.post('requestRenderData', [annodata.docData]);
        
        // BEGIN adapted from Util.embed() in util.js 

        // BEGIN adapted from end of annotator_ui.js
        dispatcher.
          on('dataReady', rememberData).
          on('mousedown', onMouseDown).
          on('mouseup', onMouseUp).
          on('mousemove', onMouseMove);
        
        // END adapted from end of annotator_ui.js

      },
      
      resize: function(width, height) {
        dispatcher.post('requestRenderData', [annodata.docData]);
      }

    };
  }
});