setOldClass("TextDocument")
setOldClass("BratDocData")

#' Get input for brat HTML widget
#' 
#' @param x An object to be transformed.
#' @rdname BratDocData
#' @name BratDocData
NULL

#' @export
is.BratDocData <- function(x){
  x
}

#' @export
as.BratDocData <- function(x, what = "POS"){
  if (what == "POS"){
    
  }
  
  sapply(subset(NLP::annotation(x), type == "word")$features, `[[`, "POS")
  NLP::features(millenium_declaration_annotated, "sentence")
  
}

