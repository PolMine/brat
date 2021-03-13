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


#' @param data Data to be passed into widget.
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
#' brat(data)
brat <- function(data = list(), width = NULL, height = NULL) {
  
  x <- list(data = data)
  
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