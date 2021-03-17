library(NLP)
library(openNLP)

md <- paste(readLines("~/Lab/github/brat/data-raw/MilleniumDeclaration.txt"), collapse = "\n")
md <- gsub("\n\n", "\n", md)

s <- String(md)

sent_token_annotator <- Maxent_Sent_Token_Annotator()
word_token_annotator <- Maxent_Word_Token_Annotator()
pos_token_annotator <- Maxent_POS_Tag_Annotator(language = "en")
entity_annotator <- Maxent_Entity_Annotator(language = "en")

a <- annotate(
  s,
  list(sent_token_annotator, word_token_annotator, pos_token_annotator, entity_annotator)
)

millenium_declaration_annotated <- AnnotatedPlainTextDocument(
  s = s,
  a = a,
  meta = list()
)

save(
  millenium_declaration_annotated,
  file = "~/Lab/github/brat/data/millenium_declaration.RData",
  compress = "xz"
)
