HTMLWidgets.widget({

  name: "brat",
  
  type: "output",
  
  factory: function(el, width, height) {
    
    var annodata;
    var dispatcher;
    
    var webFontURLs = [
      './static/fonts/Astloch-Bold.ttf',
      './static/fonts/PT_Sans-Caption-Web-Regular.ttf',
      './static/fonts/Liberation_Sans-Regular.ttf'
    ];
    
    return {
      renderValue: function(x) {
        
        annodata = x;
        dispatcher = new Dispatcher();
        var visualizer = new Visualizer(dispatcher, el.id, webFontURLs);
        console.log(visualizer.svg);
        annodata.docData.collection = null;
        dispatcher.post('collectionLoaded', [annodata.collData]);
        dispatcher.post('requestRenderData', [annodata.docData]);


      },
      
      resize: function(width, height) {
        console.log("resize widget");
        dispatcher.post('requestRenderData', [annodata.docData]);
        return undefined;
      }

    };
  }
});