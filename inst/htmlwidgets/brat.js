HTMLWidgets.widget({

  name: "brat",
  
  type: "output",
  
  factory: function(el, width, height) {
    

    var visualizer;
    document.data = undefined;
    document.annotationsUpdated = 0;
    document.code = undefined;
    
    // still necessary? loading fonts is suppressed
    var webFontURLs = [
      './static/fonts/Astloch-Bold.ttf',
      './static/fonts/PT_Sans-Caption-Web-Regular.ttf',
      './static/fonts/Liberation_Sans-Regular.ttf'
    ];
    
    
    return {
      renderValue: function(x) {
        
        $('#' + el.id).empty().removeClass("hasSVG"); // creating new widget will not work otherwise
        
        document.data = x; // make it available globally
        document.code = document.data.collData.entity_types[0].type
        
        // BEGIN adapted from Util.embed() in util.js 
        document.dispatcher = new Dispatcher();
        visualizer = new Visualizer(document.dispatcher, el.id, webFontURLs);

        document.data.docData.collection = null;
        document.dispatcher.post('collectionLoaded', [document.data.collData]);
        document.dispatcher.post('requestRenderData', [document.data.docData]);
        
        // END adapted from Util.embed() in util.js 
        AnnotatorUI(document.dispatcher, visualizer.svg);
        
        el.focus()
        
        document.dispatcher.post('collectionLoaded', [document.data.collData]);
        document.dispatcher.post('requestRenderData', [document.data.docData]);

      },
      
      resize: function(width, height) {
        document.dispatcher.post('requestRenderData', [document.data.docData]);
      }

    };
  }
});