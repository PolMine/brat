# this is example is the R version of the example used in the tutorial page
# 'embedding brat visualisations' at https://brat.nlplab.org/embed.html

example_doc_data <- list(
  text = "Ed O'Kelley was the man who shot the man who shot Jesse James.",
  entities = list(
    list('T1', 'Person', list(c(0L, 11L))),
    list('T2', 'Person', list(c(20L, 23L))),
    list('T3', 'Person', list(c(37L, 40L))),
    list('T4', 'Person', list(c(50L, 61L)))
  ),
  relations = list(
    list('R1', 'Anaphora', list(list('Anaphor', 'T2'), list('Entity', 'T1')))
  )
)

example_coll_data <- list(
  entity_types = list(list(
    type = "Person",
    labels = c("Person", "Per"),
    bgColor = "#7fa2ff",
    borderColor = "darken",
    arcs = list(list(targets = list("Person")))
  )),
  relation_types = list(list(
    type = "Anaphora",
    labels = c("Anaphora", "Ana"),
    dashArray = "3,3",
    color = "purple",
    args = list(
      list(role = "Anaphor", targets = "Person"),
      list(role = "Entity", targets = "Person")
    )
   ))
)

