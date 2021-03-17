library(polmineR)

p <- partition(
  "GERMAPARLVRT",
  plenary_protocol_date = "2010-01-20",
  speaker_name = "Angela Merkel",
  xml = "nested"
)
sc <- as(p, "subcorpus")
merkel <- as(sc, "AnnotatedPlainTextDocument")

save(merkel, file = "~/Lab/github/brat/data/merkel.RData", compress = "xz")
