#' Brat shiny HTML widget 
#' 
#' @param doc_dir 
#' @param ann_file File with annotations (brat standoff format). If not stated
#'   explicitly, the file is assumed to be in the same directory as txt file yet
#'   with *.ann file extension.
#' @param coll_data bla bla
#' @importFrom shiny titlePanel sidebarLayout radioButtons reactiveValues
#' @importFrom xfun with_ext sans_ext
#' @importFrom shinythemes shinytheme
#' @export brainy
#' @rdname brainy
#' @examples 
#' doc_dir <- system.file(package = "brat", "extdata", "sample_data")
#' 
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
#' if (interactive()) brainy(doc_dir = doc_dir, coll_data = coll_data)
#' brainy(doc_dir = "~/Lab/github/brat/inst/extdata/sample_data", coll_data = coll_data)
brainy <- function(doc_dir,  coll_data) { 
  
  txt_files <- sans_ext(basename(Sys.glob(file.path(doc_dir, "*.txt"))))

  ui <- fluidPage(
    theme = shinytheme("cerulean"),
    useShinyjs(),
    extendShinyjs(
      text = 'shinyjs.setCode = function(code){document.code = code}',
      functions = c("msg", "printDoc", "setText", "setEntities", "setCode", "requestRenderData")
    ),
    
    titlePanel(title = "brainy the brat shiny app"),
    
    sidebarLayout(
      sidebarPanel(
        
        selectInput(
          inputId = "doc_selected",
          label = "Document Selection",
          choices = basename(sans_ext(txt_files))
        ),
        
        radioButtons(
          inputId = "type",
          choices = sapply(coll_data[["entity_types"]], `[[`, "type"),
          label = "Named Entity Annotation"
        )
      ),
      
      mainPanel(
        bratOutput("brat")
      )
    )
  )
  
  server <- function(input, output, session){
    
    observeEvent(input$type, js$setCode(input$type))
    
    observeEvent(
      input$doc_selected,
      {
        txt_file <- file.path(doc_dir, paste(input$doc_selected, "txt", sep = "."))
        doc_data <- read_doc_data(
          txt_file = file.path(doc_dir, paste(input$doc_selected, "txt", sep = ".")),
          ann_file = with_ext(txt_file, "ann")
        )
        bridget <- brat(doc_data = doc_data, coll_data = coll_data)
        output$brat <- renderBrat(bridget)
      }
    )
    
    observeEvent(
      input$annotations_updated,
      {
        # f <- write_ann_file(input$document_data, ann_file = ann_file)
        f <- 1L
        message("... writing annotations file: ", f)
      }
    )

    observeEvent(
      input$done,
      stopApp(returnValue = ann_file)
    )
  }
  
  shinyApp(ui, server)
}
