#' Brat HTML widget 
#' 
#' @param doc_data bla bla
#' @param coll_data bla bla
#' @importFrom miniUI miniPage miniContentPanel gadgetTitleBar miniButtonBlock
#'   miniTabstripPanel miniTabPanel
#' @importFrom shiny tags runGadget paneViewer textAreaInput observeEvent
#'   stopApp reactiveValues icon observe actionButton
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
#'   ),
#'   relations = list()
#' )
#' coll_data <- list(
#'   entity_types = list(
#'     list(
#'       type = "Person",
#'       labels = c("Person", "Per"),
#'       bgColor = RColorBrewer::brewer.pal(8, "Accent")[1],
#'       borderColor = "darken",
#'       arcs = list(list(targets = list("Person")))
#'     ),
#'     list(
#'       type = "Organization",
#'       labels = c("Organization", "Org"),
#'       bgColor = RColorBrewer::brewer.pal(8, "Accent")[2],
#'       borderColor = "darken"
#'     ),
#'     list(
#'       type = "Location",
#'       labels = c("Location", "Loc"),
#'       bgColor = RColorBrewer::brewer.pal(8, "Accent")[3],
#'       borderColor = "darken"
#'     )
#'   ),
#'   relation_types = list(list(
#'     type = "Anaphora",
#'     labels = c("Anaphora", "Ana"),
#'     dashArray = "3,3",
#'     color = "purple",
#'     args = list(
#'       list(role = "Anaphor", targets = "Person"),
#'       list(role = "Entity", targets = "Person")
#'     )
#'    ))
#' )
#' if (interactive()) a <- bradget(doc_data = doc_data, coll_data = coll_data)
#' 
#' # A second example 
#' 
#' library(NLP)
#' merkel_min <- merkel
#' merkel_min$annotation <- merkel$annotation[merkel$annotation$type == "ner"]
#' d <- as.BratDocData(merkel_min)
#' d[["relations"]] <- list()
#' collData <- list(
#'   entity_types = list(list(
#'     type = "ner",
#'     labels = c("Named Entity", "NE"),
#'     bgColor = "#7fa2ff",
#'     borderColor = "darken",
#'     arcs = list(list(targets = list("ner")))
#'   )),
#'   relation_types = list(list(
#'     type = "Anaphora",
#'     labels = c("Anaphora", "Ana"),
#'     dashArray = "3,3",
#'     color = "purple",
#'     args = list(
#'       list(role = "Anaphor", targets = "ner"),
#'       list(role = "Entity", targets = "ner")
#'     )
#'    ))
#' )
#' if (interactive()) bradget(doc_data = d, coll_data = collData)
#' @importFrom shinyjs useShinyjs extendShinyjs js
#' @importFrom NLP Annotation AnnotatedPlainTextDocument String
#' @importFrom shinyWidgets prettyRadioButtons
#' @importFrom htmltools div
#' @return A `AnnotatedPlainTextDocument` object as defined in the NLP package.
bradget <- function(doc_data, coll_data) { 
  
  widget <- brat(doc_data = doc_data, coll_data = coll_data)
  values <- reactiveValues()
  
  ui <- miniPage(
    tags$style(
      ".buttongroup {align-items: center; justify-content: center; background-color: #f2f2f2; padding: 0 6px; display: flex; flex: none; border-top: 1px solid #ddd;}"
    ),
    useShinyjs(),
    extendShinyjs(text = 'shinyjs.setCode = function(code){document.code = code}', functions = "setCode"),
    gadgetTitleBar(title = "BRAT Annotation Gadget"),
    miniContentPanel( bratOutput("brat")),
    div(
      shinyWidgets::prettyRadioButtons(
        "type",
        choices = sapply(coll_data[["entity_types"]], `[[`, "type"),
        label = "", inline = TRUE
      ),
      class = "buttongroup"
    )
  )
  
  server <- function(input, output, session) {
    
    output$brat <- renderBrat(widget)
    
    observeEvent(input$type, js$setCode(input$type))

    observeEvent(
      input$done,
      stopApp(
        returnValue = AnnotatedPlainTextDocument(
          s = String(doc_data[["text"]]),
          a = Annotation(
            id = sapply(
              unlist(input$annotations[["ID"]]),
              function(id) as.integer(gsub("^.*?(\\d+).*?$", "\\1", id))
            ),
            type = unlist(input$annotations[["type"]]),
            start = unlist(input$annotations[["left"]]),
            end = unlist(input$annotations[["right"]])
          )
        )
      )
    )
  }
  
  runGadget(ui, server, viewer = paneViewer())
}
