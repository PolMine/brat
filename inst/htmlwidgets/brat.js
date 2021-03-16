HTMLWidgets.widget({

  name: "brat",
  
  type: "output",
  
  factory: function(el, width, height) {
    
    // el.style.overflow = "scroll";
    
    document.code = "Person";
    document.annotations = {id: [], type: [], start: [], end: []}
    var dispatcher; // define here to make it available globally
    
    // still necessary? loading fonts is suppressed
    var webFontURLs = [
      './static/fonts/Astloch-Bold.ttf',
      './static/fonts/PT_Sans-Caption-Web-Regular.ttf',
      './static/fonts/Liberation_Sans-Regular.ttf'
    ];
    
    
    return {
      renderValue: function(x) {
        
        document.data = x; // make it available globally
        document.annotationsUpdated = 0;
        
        // turn document data into structure that can be returned easily
        for (i = 0; i < document.data.docData.entities.length; i++){
          document.annotations.id.push(document.data.docData.entities[i][0]);
          document.annotations.type.push(document.data.docData.entities[i][1]);
          document.annotations.start.push(document.data.docData.entities[i][2][0][0]);
          document.annotations.end.push(document.data.docData.entities[i][2][0][1]);
        };
        Shiny.onInputChange('annotations', document.annotations);

        // BEGIN adapted from Util.embed() in util.js 
        dispatcher = new Dispatcher();
        var visualizer = new Visualizer(dispatcher, el.id, webFontURLs);

        document.data.docData.collection = null;
        dispatcher.post('collectionLoaded', [document.data.collData]);
        dispatcher.post('requestRenderData', [document.data.docData]);
        // END adapted from Util.embed() in util.js 
        
        anno_ui = AnnotatorUI(dispatcher, visualizer.svg);

      },
      
      resize: function(width, height) {
        dispatcher.post('requestRenderData', [document.data.docData]);
      }

    };
  }
});