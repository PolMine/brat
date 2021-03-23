#' Brat shiny HTML widget 
#' 
#' @param doc_dir Diretory with plaint text documents (*.txt) and annotation
#'   files (*.ann).
#' @param coll_data Configuration of annotation scheme.
#' @param theme The theme passed into shinythemes.
#' @importFrom shiny titlePanel sidebarLayout radioButtons reactiveValues
#'   fluidPage mainPanel selectInput shinyApp sidebarPanel icon br
#' @importFrom xfun with_ext sans_ext
#' @importFrom shinythemes shinytheme
#' @export brainy
#' @rdname brainy
#' @examples 
#' library(brat)
#' 
#' # Prepare directory with .txt and .ann files: The package includes some 
#' # sample files - we create a temporary copy
#' 
#' doc_dir_pkg <- system.file(package = "brat", "extdata", "sample_data")
#' doc_dir <- file.path(tempdir(), "brat")
#' if (!dir.exists(doc_dir)) dir.create(doc_dir)
#' if (length(list.files(doc_dir)) > 0L) file.remove(list.files(doc_dir, full.names = TRUE))
#' for (file in list.files(doc_dir_pkg, full.names = TRUE)){
#'   file.copy(from = file, to = file.path(doc_dir, basename(file)))
#' }
#' 
#' # Define collection data
#' 
#' coll_data <- list(
#'   entity_types = list(
#'     list(
#'       type = "Person",
#'       labels = c("Person", "Per"),
#'       bgColor = RColorBrewer::brewer.pal(8, "Accent")[1],
#'       borderColor = "darken",
#'       arcs = list(list(targets = list("Person"))),
#'       children = list()
#'     ),
#'     list(
#'       type = "Organization",
#'       labels = c("Organization", "Org"),
#'       bgColor = RColorBrewer::brewer.pal(8, "Accent")[2],
#'       borderColor = "darken",
#'       arcs = list(list(targets = list("Person"))),
#'       children = list()
#'     ),
#'     list(
#'       type = "Location",
#'       labels = c("Location", "Loc"),
#'       bgColor = RColorBrewer::brewer.pal(8, "Accent")[3],
#'       borderColor = "darken",
#'       arcs = list(list(targets = list("Person"))),
#'       children = list()
#'     ),
#'     list(
#'       type = "Date",
#'       labels = c("Date", "Date"),
#'       bgColor = RColorBrewer::brewer.pal(8, "Accent")[4],
#'       borderColor = "darken",
#'       arcs = list(list(targets = list("Person"))),
#'       children = list()
#'     )
#'   ),
#'   relation_types = list(
#'     list(
#'       type = "Anaphora",
#'       labels = c("Anaphora", "Ana"),
#'       dashArray = "3,3",
#'       color = "purple",
#'       args = list(
#'         list(role = "Anaphor", targets = "Person"),
#'         list(role = "Entity", targets = "Person")
#'       )
#'      ),
#'      list(
#'       type = "Birthday",
#'       labels = c("Birthday", "born"),
#'       dashArray = "3,3",
#'       color = "blue",
#'       args = list(
#'         list(role = "Anaphor", targets = "Person"),
#'         list(role = "Entity", targets = "Person")
#'       )
#'     )
#'   )
#' )
#' 
#' # Run brainy app (but only in interactive mode)
#' 
#' if (interactive()){
#'   brainy(doc_dir = doc_dir, coll_data = coll_data)
#' }
#' @export brainy
brainy <- function(doc_dir,  coll_data, theme = "paper") { 
  
  txt_files <- sans_ext(basename(Sys.glob(file.path(doc_dir, "*.txt"))))

  ui <- shiny::fluidPage(
    theme = shinytheme(theme),
    useShinyjs(),
    extendShinyjs(
      text = "
        shinyjs.requestRenderData = function(x){
          document.data.docData = x[0];
          document.dispatcher.post('requestRenderData', [document.data.docData]);
        };
        shinyjs.setCode = function(code){document.code = code}
      ",
      functions = c("setDocData", "setCode", "requestRenderData")
    ),
    
    titlePanel(title = "brainy [brat shiny app]"),
    
    sidebarLayout(
      sidebarPanel(
        
        selectInput(
          inputId = "doc_selected",
          label = "Document Selection",
          choices = basename(sans_ext(txt_files))
        ),
        actionButton("previous_doc", "", icon = icon("backward")),
        actionButton("next_doc", "", icon = icon("forward")),
        br(),
        br(),
        radioButtons(
          inputId = "type",
          choices = sapply(coll_data[["entity_types"]], `[[`, "type"),
          label = "Named Entity Annotation"
        ),
        radioButtons(
          inputId = "type",
          choices = sapply(coll_data[["relation_types"]], `[[`, "type"),
          label = "Relation Annotation"
        ),
        actionButton("stop", "Stop", icon = icon("power-off"))
      ),
      
      mainPanel(
        bratOutput("brat")
      )
    )
  )
  
  server <- function(input, output, session){
    
    values <- shiny::reactiveValues()

    observeEvent(input$type, js$setCode(input$type))
    
    observeEvent(
      input$doc_selected,
      {
        fname <- file.path(doc_dir, paste(input$doc_selected, "txt", sep = "."))
        values[["annofile"]] <- with_ext(fname, "ann")
        doc_data <- read_doc_data(txt_file = fname, ann_file = values[["annofile"]])
        
        if (length(values$doc_rendered) == 0L){
          bridget <- brat(doc_data = doc_data, coll_data = coll_data)
          output$brat <- renderBrat(bridget)
          values$doc_rendered <- input$doc_selected
        } else {
          js$requestRenderData(doc_data)
          values$doc_rendered <- input$doc_selected
        }
      }
    )
    
    observeEvent(
      input$annotations_updated,
      {
        annofile <- write_ann_file(input$document_data, ann_file = values[["annofile"]])
        message("... writing annotations file: ", values[["annofile"]])
      }
    )

    observeEvent(input$stop, stopApp())
  }
  
  shinyApp(ui, server)
}
