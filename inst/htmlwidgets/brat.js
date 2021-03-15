HTMLWidgets.widget({

  name: "brat",
  
  type: "output",
  
  factory: function(el, width, height) {
    
    var annodata;
    
    var webFontURLs = [
      './static/fonts/Astloch-Bold.ttf',
      './static/fonts/PT_Sans-Caption-Web-Regular.ttf',
      './static/fonts/Liberation_Sans-Regular.ttf'
    ];
    
    return {
      renderValue: function(x) {
        
        annodata = x;
        Util.embed(el.id, annodata.collData, annodata.docData, webFontURLs);

      },
      
      resize: function(width, height) {
        console.log("resize widget");
        // Util.embed(el.id, collData, annodata.data, webFontURLs);
        return undefined;
      }

    };
  }
});