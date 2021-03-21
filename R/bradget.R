#' Brat HTML widget 
#' 
#' @param txt_file File with plan text of document to be annotated.
#' @param ann_file File with annotations (brat standoff format). If not stated
#'   explicitly, the file is assumed to be in the same directory as txt file yet
#'   with *.ann file extension.
#' @param coll_data bla bla
#' @importFrom miniUI miniPage miniContentPanel gadgetTitleBar miniButtonBlock
#'   miniTabstripPanel miniTabPanel
#' @importFrom shiny tags runGadget paneViewer textAreaInput observeEvent
#'   stopApp observe actionButton
#' @importFrom xfun with_ext
#' @export bradget
#' @rdname brat
#' @examples 
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
#' 
#' txt_src <- system.file(package = "brat", "extdata", "sample_data", "edokelley.txt")
#' ann_src <- system.file(package = "brat", "extdata", "sample_data", "edokelley.ann")
#' txt_file <- file.path(tempdir(), "edokelley.txt")
#' ann_file <- file.path(tempdir(), "edokelley.ann")
#' file.copy(txt_src, txt_file)
#' file.copy(ann_src, ann_file)
#' 
#' if (interactive()) bradget(txt_file = txt_file, coll_data = coll_data)
#' 
#' # A second example 
#' 
#' library(NLP)
#' merkel_min <- merkel
#' merkel_min$annotation <- merkel$annotation[merkel$annotation$type == "ner"]
#' 
#' ann_file <- write_ann_file(x = as.doc_data(merkel_min))
#' txt_file <- with_ext(ann_file, ".txt")
#' cat(merkel_min$content, file = txt_file)
#' 
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
#' 
#' if (interactive()) bradget(txt_file = txt_file, coll_data = collData)
#' @importFrom shinyjs useShinyjs extendShinyjs js
#' @importFrom NLP Annotation AnnotatedPlainTextDocument String
#' @importFrom shinyWidgets prettyRadioButtons
#' @importFrom htmltools div
#' @return A `AnnotatedPlainTextDocument` object as defined in the NLP package.
bradget <- function(txt_file, ann_file = with_ext(txt_file, "ann"), coll_data) { 
  
  doc_data <- read_doc_data(txt_file = txt_file, ann_file = ann_file)
  bridget <- brat(doc_data = doc_data, coll_data = coll_data)

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
    
    output$brat <- renderBrat(bridget)
    
    observeEvent(input$type, js$setCode(input$type))
    
    observeEvent(
      input$annotations_updated,
      {
        f <- write_ann_file(input$document_data, ann_file = ann_file)
        message("... writing annotations file: ", f)
      }
    )

    observeEvent(input$done,stopApp(returnValue = ann_file))
  }
  
  runGadget(ui, server, viewer = paneViewer())
}
