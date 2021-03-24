library(NLP)
library(openNLP)
library(xfun)

annotators <- list(Maxent_Sent_Token_Annotator(), Maxent_Word_Token_Annotator())

files <- Sys.glob("~/Lab/github/brat/inst/extdata/sample_data/*.txt")

for (f in files){
  message(f)
  x <- gsub("\n\n", "\n", paste(readLines(f), collapse = "\n"))
  a <- annotate(String(x), annotators)
  saveRDS(a, file = with_ext(f, "rds"), compress = "xz")
}
