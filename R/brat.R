#' Create brat htmlwidget
#' 
#' This is a lightweight wrapper for the brat annotation tool.
#' @export brat
#' @aliases brat-package brat
#' @docType package
#' @name brat
#' @import methods
#' @rdname brat
#' @author Andreas Blaette
NULL


#' @param doc_data Data to be passed into widget.
#' @param coll_data Collection data.
#' @param width The width of the widget.
#' @param height The height of the widget.
#' @param outputId The ID of the widget.
#' @rdname brat
#' @import htmlwidgets
#' @export
#' @importFrom htmlwidgets createWidget
#' @examples 
#' if (interactive()){
#'   brat(
#'     doc_data = example_doc_data,
#'     coll_data = example_coll_data
#'   )
#' }
#' 
#' # A second example
#' 
#' library(NLP)
#' merkel_min <- merkel
#' merkel_min$annotation <- merkel$annotation[merkel$annotation$type == "ner"]
#' # d <- as.BratDocData(merkel_min)
#' # collData <- list(
#' # entity_types = list(list(
#' #    type = "ner",
#' #    labels = c("Named Entity", "NE"),
#' #     bgColor = "#7fa2ff",
#' #    borderColor = "darken"
#' #   ))
#' # )
#' if (interactive()) brat(doc_data = d, coll_data = collData)
brat <- function(doc_data = list(), coll_data = list(), width = NULL, height = NULL) {
  
  x <- list(docData = doc_data, collData = coll_data)
  
  htmlwidgets::createWidget(name = "brat", x = x, width = width, height = height)
}

#' @rdname brat
#' @export
bratOutput <- function(outputId, width = "100%", height = "400px") {
  shinyWidgetOutput(outputId, "brat", width, height, package = "brat")
}

#' @param env An environment.
#' @param quoted A `logical` value.
#' @param expr An expression.
#' @rdname brat
#' @export
#' @importFrom htmlwidgets shinyRenderWidget
renderBrat <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, bratOutput, env, quoted = TRUE)
}


#' Annotated Millenium Declaration
#' 
#' @rdname millenium_declaration 
#' @format A `AnnotatedPlainTextDocument` object as defined in the NLP package.
"millenium_declaration_annotated"

#' Annotated Speech of Angela Merkel
#' 
#' @rdname merkel
#' @format A `AnnotatedPlainTextDocument` object as defined in the NLP package.
"merkel"

#' Brat example data
#' @rdname brat_example_data
"example_doc_data"

#' Brat example data
#' @rdname brat_example_data
"example_coll_data"
