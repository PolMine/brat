#' @export read_doc_data
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

#' @examples 
#' write_ann_file(example_doc_data)
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

#' @examples 
#' ann_file <- system.file(package = "brat", "extdata", "sample_data", "edokelley.ann")
#' as.Annotation(ann_file)
as.Annotation.character <- function(ann_file){
  doc <- read_doc_data(ann_file = ann_file)
  entities <- Annotation(
    id = as.integer(gsub("^.*?(\\d+).*?$", "\\1", sapply(doc[["entities"]], `[[`, 1L))),
    type = sapply(doc[["entities"]], `[[`, 2L),
    start = sapply(doc[["entities"]], function(e) e[[3]][[1]][[1]]),
    end = sapply(doc[["entities"]], function(e) e[[3]][[1]][[2]])
  )
  # relations <- Annotation()
  entities
}
