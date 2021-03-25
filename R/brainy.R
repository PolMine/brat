#' Brat shiny HTML app.
#' 
#' Call brainy, the brat shiny app to annotate multiple documents.
#' 
#' The function takes a document directory (`doc_dir`) as input. Plain text
#' files present in the directory (.txt file extension) will be available
#' as documents to be annotated. 
#' 
#' Annotations for these documents will be stored in the same directory using
#' the brat standoff annotation format (.ann file extension). The name of the
#' annotation file will be identical with text document, just using the .ann file
#' extension. Annotation files that are present before annotating documents will
#' be parsed and annotations are shown.
#' 
#' If the document has already been tokenized, use the `Annotation` class of the
#' NLP package to infuse this information for the annotation exercise. In this
#' case, when creating a new annotation, the span of text highlighted will be
#' checked against the tokenization and character offsets will be mapped on the
#' existing tokenisation. This can also be useful for speeding up annotation,
#' because annotators need not highlight the exact beginning and end of tokens
#' to create an annotation that looks all right.
#' 
#' Files with an existing token annotation are expected to have the same file
#' name as the document, using an .rds file extension. These rds files are
#' expected to be `Annotation` class objects that have been stored using
#' `saveRDS()`.
#' 
#' @param doc_dir Diretory with plaint text documents (*.txt), annotation files
#'   (*.ann) and rds files with `Annotation` objects stored using `saveRDS()`.
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
#' # Define collection data (= available annotations)
#' 
#' annotation_colors <- RColorBrewer::brewer.pal(8, "Accent")
#' coll_data <- list(
#'   entity_types = list(
#'     entity("Person", bgColor = annotation_colors[1]),
#'     entity("Organisaation", bgColor = annotation_colors[2]),
#'     entity("Location", bgColor = annotation_colors[3]),
#'     entity("Date", bgColor = annotation_colors[4])
#'   ),
#'   relation_types = list(
#'     relation("Anaphora", color = annotation_colors[5], roles = c("Anaphor", "Entity"), targets = c("Person", "Person")),
#'     relation("Anaphora", color = annotation_colors[6], roles = c("Anaphor", "Entity"), targets = c("Person", "Person"))
#'   )
#' )
#' 
#' # Run brainy app (but only in interactive mode)
#' 
#' if (interactive()) brainy(doc_dir = doc_dir, coll_data = coll_data)
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
        shinyjs.setCode = function(code){document.code = code};
        shinyjs.updateLastEntityAnnotated = function(x){
          document.data.docData.entities[document.data.docData.entities.length - 1] = x[0];
          document.dispatcher.post('requestRenderData', [document.data.docData]);
        };
      ",
      functions = c("setDocData", "setCode", "requestRenderData", "updateLastEntityAnnotated")
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
        
        nlp_file <- with_ext(fname, "rds")
        if (file.exists(nlp_file)){
          
          a <- readRDS(nlp_file)
          if (inherits(a, "Annotation")){
            a_word <- a[a$type == "word"]
            values[["offset"]] <- matrix(
              data = c(a_word$start, a_word$end),
              ncol = 2, byrow = FALSE
            )
            message("Found character offset annotations!")
          } else {
            warning(sprintf("Found rds file %s but it is not an Annotation object", nlp_file))
          }
        }
        
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
      input$last_entity_annotated,
      {
        start_vec <- which(as.integer(input$last_entity_annotated[3]) - values[["offset"]][,1] >= 0L)
        n_start <- start_vec[length(start_vec)]
        n_end <- which(values[["offset"]][,2] - as.integer(input$last_entity_annotated[4]) >= 0)[1]
        js$updateLastEntityAnnotated(
          list(
            input$last_entity_annotated[1],
            input$last_entity_annotated[2],
            list(c(values[["offset"]][n_start, 1] - 1L, values[["offset"]][n_end, 2]))
          )
        )
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
