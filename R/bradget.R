#' Brat HTML widget 
#' 
#' @param doc_data bla bla
#' @param coll_data bla bla
#' @importFrom miniUI miniPage miniContentPanel gadgetTitleBar miniButtonBlock
#'   miniTabstripPanel miniTabPanel
#' @importFrom shiny tags runGadget paneViewer textAreaInput observeEvent
#'   stopApp reactiveValues icon observe
#' @export bradget
#' @rdname brat
#' @examples 
#' doc_data <- list(
#'   text = "Ed O'Kelley was the man who shot the man who shot Jesse James.\n What a guy. He should be hanged.",
#'   entities = list(
#'     list('T1', 'Person', list(c(0, 11))),
#'     list('T2', 'Person', list(c(20, 23))),
#'     list('T3', 'Person', list(c(37, 40))),
#'     list('T4', 'Person', list(c(50, 61))),
#'     list('T5', 'Person', list(c(64, 68)))
#'   )
#' )
#' coll_data <- list(
#'   entity_types = list(list(
#'     type = "Person",
#'     labels = c("Person", "Per"),
#'     bgColor = "#7fa2ff",
#'     borderColor = "darken"
#'   ))
#' )
#' bradget(doc_data = doc_data, coll_data = coll_data)
bradget <- function(doc_data, coll_data) { 
  
  widget <- brat(doc_data = doc_data, coll_data = coll_data)
  values <- reactiveValues()
  
  ui <- miniPage(
    gadgetTitleBar(title = "BRAT Annotation Gadget"),
    miniTabstripPanel(
      miniTabPanel(
        "Text", icon = icon("file"),
        miniContentPanel( bratOutput("brat"))
      )
    )
    
  )
  
  server <- function(input, output, session) {
    
    output$brat <- renderBrat(widget)
    
    observeEvent(
      input$annotations_updated,
      {
        print(input$annotations)
      }
    )
    
    observeEvent(input$done, stopApp(invisible(values[["annotations"]])))
  }
  
  runGadget(ui, server, viewer = paneViewer())
}
