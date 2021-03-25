#' Configure entity settings for collection data.
#' 
#' Collection data require a definition of entities that shall be annotated.
#' This auxiliary function generates the data format ready to passed to the brat
#' JavaScript code.
#' @return A nested `list` object.
#' @param type A length-one `character` vector defining the type of annotation.
#' @param labels A `character` vector with two elements: The label to be shown
#'   over an annotation, and an abbreviation. If not stated explicitly, the type
#'   will be used as label and the first three characters of it as an
#'   abbreviation.
#' @param bgColor The background color  of the annotation.
#' @param borderColor Border color of the annotation. Defaults to "darken".
#' @export
#' @examples 
#' entity("Person", bgColor = "#7FC97F")
entity <- function(type, labels = c(type, substr(type, 1, 3)), bgColor, borderColor = "darken"){
  stopifnot(
    is.character(type), length(type) == 1L,
    is.character(labels), length(labels) == 2L,
    is.character(bgColor), length(bgColor) == 1L,
    is.character(borderColor), length(borderColor) == 1L
  )
  list(
    type = type,
    labels = labels,
    bgColor = bgColor,
    borderColor = borderColor,
    arcs = list(list(targets = list(type))),
    children = list()
  )
}

#' Define relation for configuration of collection data.
#' 
#' Annotating relations requires a definition that is part of the collection data.
#' This auxiliary definition prepares the data structure that can be passed to
#' brat JavaScript.
#' 
#' @param type The type of relation to be annoated (length-one `character` vector).
#' @param labels A `character` vector with two elements with the label to be shown 
#'   for an annotation and an abbreviation of the label that is used when necessary.
#'   Defaults to the `type` of the annotation and the first three characters of the
#'   annotation.
#' @param dashArray A length-one `character` vector defining the visual layout
#'   of arrows.
#' @param color The color of the annotation (length-one `character` vector).
#' @param roles A `character` vector with the same length as argument `targets`.
#' @param targets A `character` vector with the same length as argument `roles`.
#' @examples
#' relation("Anaphora", color = "purple", roles = c("Anaphor", "Entity"), targets = c("Person", "Person"))
#' @export
relation <- function(type, labels = c(type, substr(type, 1, 3)), dashArray = "3,3", color, roles, targets){
  stopifnot(
    is.character(type), length(type) == 1L,
    is.character(labels), length(labels) == 2L,
    is.character(dashArray), length(dashArray) == 1L,
    is.character(color), length(color) == 1L,
    is.character(roles), is.character(targets),
    length(roles) == length(targets)
  )
  list(
    type = type,
    labels = labels,
    dashArray = dashArray,
    color = color,
    args = lapply(1:length(roles), function(i) list(role = roles[[i]], targets = targets[[i]]))
  )
}