<!-- badges: start -->
[![R build status](https://github.com/ablaette/brat/workflows/R-CMD-check/badge.svg)](https://github.com/ablaette/brat/actions)
[![codecov](https://codecov.io/gh/PolMine/brat/branch/master/graph/badge.svg)](https://codecov.io/gh/PolMine/brat/branch/master)
<!-- badges: end -->

## The brat R package

### Why yet another annotation tool?

The ['brat' rapid annotation tool](https://brat.nlplab.org/) is a classic piece of software for text annotation tasks that involve that annotation of spans of texts (such as named entities) and relations among entites. Its visualization engine has been used as a JavaScript library that is integrated into more recent developments such as [WebAnno](https://webanno.github.io/webanno/) and [INCEpTION](https://inception-project.github.io/). During this evolution, significant advanced features such as connecting to external knowledge bases and active learning capabilities have been added.

But there is a set of annotation tasks with limited complexity. A more lightweight approach that does not require hosting a server (including managing users and taking care of security) may do: This is the essential idea behind the brat R package. The core functionality of the package is as follows:

- Building on the original brat JavaScript code, the function `brat()` will generate a [HTML widget](https://www.htmlwidgets.org/)  that is the heart of the visualization and annotation functionality of the package. The 'brat' HTML widget can also be included in Rmarkdown documents, including slides, for documenting annotation datasets. IT is also a tool to generate transparency of research.

- The function `bradget()` calls a [Shiny gadget](https://shiny.rstudio.com/articles/gadgets.html) that is designed as a simple tool for annotating a single document. It may be most useful when used in the context of [RStudio](https://rstudio.com/).

- The `brainy()` function generates a [Shiny app](https://shiny.rstudio.com/) for annotating multiple documents. For most annotation tasks, this app will be the genuinely relevant aspect of the brat R package.


### Input and output data formats

The toolset thus exposed is intended to be as flexible as possible, so that it can be integrated into annotation workflows of single researchers of teams, irrespective of the machinery that is used for managing and analysing data. This guides the choices made for the data formats that shall are sufficiently generic to facilitate data exchange:

- Classes and data formats defined in the [NLP](https://CRAN.R-project.org/package=NLP) package (classes `Annotation` and `AnnotatedPlainTextDocument`) are versatile to combine several annotation layers represented as a standoff annotation. This data format can be generated from most tools in the R world. It serves as an input to `brat()`, `bradget()`, and `brainy()`.

- Annotations of entities and relations generated using `bradget()` and `brainy()` will be stored continuously in the [brat standoff format](https://brat.nlplab.org/standoff.html), a plain and simple text file with tab separated values. Data can be transformed into the `Annotations` class of the NLP package and transformed according to the needs of your data processing workflow.


### Working in teams

One nice aspect of using the brat standoff format ('ann' files) as the primary output of `bradget()` and `brainy()` is that this non-binary, plain text data format is suited well to be kept in [git](https://git-scm.com/) repositories. So annotators can store results in different folders or branches of a git repository, and by using `git merge`, it will be possible to realize an annotation task with multiple users.

To sum up: If you have an annotation task that is complex and that should be administered centrally, go for one of the server-based options. If your task is plain and essentially simple, and if you feel confident to use git for research data management - consider using this package. It is designed to offer a lightweight and flexible option for text annotation tasks.


## License

The brat JavaScript code is under the [MIT](https://opensource.org/licenses/MIT) license. The MIT license also applies also to other JavaScript libraries (jQuery, jQuery SVG and sprintf) that are included in this package.

The R package brat is under the [GPL-3](https://www.gnu.org/licenses/gpl-3.0.html) license as a standard license in the R domain.


## Quotation

The brat JavaScript code is the essence of this package. If you use this package, it will be good practice to honour the original work of the team behind brat by including the following reference, as recommended on the [Homepage of the brat project](https://brat.nlplab.org/about.html):

Pontus Stenetorp, Sampo Pyysalo, Goran Topić, Tomoko Ohta, Sophia Ananiadou and Jun'ichi Tsujii (2012). brat: a Web-based Tool for NLP-Assisted Text Annotation. In Proceedings of the Demonstrations Session at EACL 2012. 


## Contributing

[to be written]



