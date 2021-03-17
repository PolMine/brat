setOldClass("TextDocument")
setOldClass("BratDocData")

#' Get input for brat HTML widget
#' 
#' @param x An object to be transformed.
#' @rdname BratDocData
#' @name BratDocData
NULL

#' @export
#' @examples
#' library(NLP)
#' merkel_min <- merkel
#' 
#' # We do not want to show all annotations
#' merkel_min$annotation <- merkel$annotation[merkel$annotation$type == "ner"]
#' d <- as.BratDocData(merkel_min)
#' @rdname BratDocData
#' @export as.BratDocData
as.BratDocData <- function(x){
  a <- x$annotation
  list(
    text = x$content,
    entities = lapply(
      1L:length(a),
      function(i)
        list(
          sprintf("T%d", i),
          a[[i]]$type,
          list(c(a[[i]]$start - 1L, a[[i]]$end)) # JavaScript indexing is zero-based
        )
    )
  )
}
