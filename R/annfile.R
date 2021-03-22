#' Data conversion for brat
#' 
#' @param txt_file Plain text file with fulltext of document.
#' @param ann_file A tab-separated file with annotations, brat standoff format.
#' @rdname doc_data
#' @export read_doc_data
#' @examples
#' txt_file <- system.file(package = "brat", "extdata", "sample_data", "edokelley.txt")
#' ann_file <- system.file(package = "brat", "extdata", "sample_data", "edokelley.ann")
#' doc_data <- read_doc_data(txt_file, ann_file)
read_doc_data <- function(txt_file, ann_file){
  li <- if (file.exists(ann_file)) readLines(ann_file) else character()
  list(
    text = if (!missing(txt_file)) paste(readLines(txt_file), collapse = "\n") else character(),
    entities = lapply(
      strsplit(x = li[grep("^T\\d+\\s", li, perl = TRUE)], split = "\\s+"),
      function(l){
        list(l[[1]], l[[2]], list(c(as.integer(l[[3]]), as.integer(l[[4]]))))
      }
    ),
    relations = lapply(
      strsplit(x = li[grep("^R\\d+\\s", li, perl = TRUE)], split = "\\s+"),
      function(l){
        list(l[[1]], l[[2]], lapply(strsplit(c(l[[3]], l[[4]]),  split = ":"), as.list))
      }
    )
  )
}

#' @export write_ann_file
#' @examples 
#' write_ann_file(example_doc_data)
#' @rdname doc_data
write_ann_file <- function(x, ann_file = tempfile(fileext = ".ann")){
  entites <- lapply(
    x[["entities"]],
    function(entity) paste(unlist(entity, recursive = TRUE), collapse = "\t")
  )
  relations <- lapply(
    x[["relations"]],
    function(rel){
      paste(
        unlist(c(rel[[1]], rel[[2]], lapply(rel[[3]], paste, collapse = ":"))),
        collapse = "\t"
      )
    }
  )
  writeLines(unlist(c(entites, relations)), con = ann_file)
  ann_file
}

#' @details The `as.Annotation()` S3 method is re-imported from the NLP package.
#' @rdname doc_data
#' @export
NLP::as.Annotation


#' @param ... Included as a matter of consistency with `NLP::as.Annotation()`.
#' @examples 
#' ann_file <- system.file(package = "brat", "extdata", "sample_data", "edokelley.ann")
#' as.Annotation(x = ann_file)
#' @rdname doc_data
#' @importFrom NLP as.Annotation
#' @export
as.Annotation.character <- function(x, ...){
  doc <- read_doc_data(ann_file = x)
  entities <- Annotation(
    id = as.integer(gsub("^.*?(\\d+).*?$", "\\1", sapply(doc[["entities"]], `[[`, 1L))),
    type = sapply(doc[["entities"]], `[[`, 2L),
    start = sapply(doc[["entities"]], function(e) e[[3]][[1]][[1]]),
    end = sapply(doc[["entities"]], function(e) e[[3]][[1]][[2]])
  )
  # relations <- Annotation()
  entities
}
