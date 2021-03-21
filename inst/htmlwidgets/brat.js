HTMLWidgets.widget({

  name: "brat",
  
  type: "output",
  
  factory: function(el, width, height) {
    
    // el.style.overflow = "scroll";
    
    var dispatcher; // define here to make it available globally
    
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
        console.log(document.data);
        document.annotationsUpdated = 0;
        document.code = document.data.collData.entity_types[0].type
        
        // BEGIN adapted from Util.embed() in util.js 
        dispatcher = new Dispatcher();
        var visualizer = new Visualizer(dispatcher, el.id, webFontURLs);

        document.data.docData.collection = null;
        dispatcher.post('collectionLoaded', [document.data.collData]);
        dispatcher.post('requestRenderData', [document.data.docData]);
        
        // END adapted from Util.embed() in util.js 
        anno_ui = AnnotatorUI(dispatcher, visualizer.svg);
        
        dispatcher.post('collectionLoaded', [document.data.collData]);
        dispatcher.post('requestRenderData', [document.data.docData]);

      },
      
      resize: function(width, height) {
        dispatcher.post('requestRenderData', [document.data.docData]);
      }

    };
  }
});