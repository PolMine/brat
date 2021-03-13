HTMLWidgets.widget({

  name: "brat",
  
  type: "output",
  
  factory: function(el, width, height) {

    return {
      renderValue: function(x) {
          
        console.log(x.data.entities);
        
        var bratLocation = ".";
        var webFontURLs = [
          bratLocation + '/static/fonts/Astloch-Bold.ttf',
          bratLocation + '/static/fonts/PT_Sans-Caption-Web-Regular.ttf',
          bratLocation + '/static/fonts/Liberation_Sans-Regular.ttf'
        ];
        
        var collData = {
          entity_types: [ {
            type   : 'Person',
            /* The labels are used when displaying the annotion, in this case
                we also provide a short-hand "Per" for cases where
                abbreviations are preferable */
            labels : ['Person', 'Per'],
            // Blue is a nice colour for a person?
            bgColor: '#7fa2ff',
            // Use a slightly darker version of the bgColor for the border
            borderColor: 'darken'
          }]
        };

        var docData = {
          text     : "Ed O'Kelley was the man who shot the man who shot Jesse James.",
          entities : [
            ['T1', 'Person', [[0, 11]] ],
            ['T2', 'Person', [[20, 23]] ],
            ['T3', 'Person', [[37, 40]] ],
            ['T4', 'Person', [[50, 61]] ]
        ]};
        console.log(docData.entities);
        
        Util.embed('htmlwidget_container', collData, x.data, webFontURLs);

      }
    };
  }
});