#' Create brat htmlwidget
#' 
#' This is a lightweight wrapper for the brat annotation tool.
#' @export brat
#' @param x Any kind of input.
#' @aliases brat-package brat
#' @docType package
#' @name brat
#' @import methods
#' @rdname brat
#' @author Andreas Blaette
NULL


#' @param document_data Data to be passed into widget.
#' @param collection_data Collection data.
#' @param width The width of the widget.
#' @param height The height of the widget.
#' @param outputId The ID of the widget.
#' @rdname brat
#' @import htmlwidgets
#' @export
#' @importFrom htmlwidgets createWidget
#' @examples 
#' data <- list(
#'   text = "Ed O'Kelley was the man who shot the man who shot Jesse James.\n What a guy. He should be hanged.",
#'   entities = list(
#'     list('T1', 'Person', list(c(0, 11))),
#'     list('T2', 'Person', list(c(20, 23))),
#'     list('T3', 'Person', list(c(37, 40))),
#'     list('T4', 'Person', list(c(50, 61))),
#'     list('T5', 'Person', list(c(64, 68)))
#'   )
#' )
#' collData <- list(
#'   entity_types = list(list(
#'     type = "Person",
#'     labels = c("Person", "Per"),
#'     bgColor = "#7fa2ff",
#'     borderColor = "darken"
#'   ))
#' )
#' brat(doc_data = data, coll_data = collData)
brat <- function(doc_data = list(), coll_data = list(), width = NULL, height = NULL) {
  
  x <- list(docData = doc_data, collData = coll_data)
  
  htmlwidgets::createWidget(name = "brat", x = x, width = width, height = height)
}

#' @rdname brat
#' @export
bratOutput <- function(outputId, width = "100%", height = "400px") {
  shinyWidgetOutput(outputId, "sigma", width, height, package = "sigma")
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