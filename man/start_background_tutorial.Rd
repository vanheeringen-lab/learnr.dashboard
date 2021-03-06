% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/start_as_tutorial.R
\name{start_background_tutorial}
\alias{start_background_tutorial}
\title{Start a learnr tutorial in the background}
\usage{
start_background_tutorial(
  name = NULL,
  package = "learnr.proto",
  r_path = NULL,
  r_args = NULL,
  host = NULL,
  port = NULL
)
}
\arguments{
\item{name}{Tutorial name. Available tutorials: "fg1", "fg2", "fg3".}

\item{package}{Tutorial package. Default: "learnr.proto" (Functional Genomics)}

\item{r_path}{Specify the R executable to use. Default: Same as current session}

\item{r_args}{Specify the R flags to use. Default: \code{--vanilla -q}}

\item{host}{Rstudio Server IP address. Required if the server is not hosting on localhost. Automatically set for rstudio.science.ru.nl.}

\item{port}{Specify the port to start the tutorial app on (must be free). Default: \code{NULL} (picks a free port for you)}
}
\description{
Start a background tutorial, which does not occupy the current session.
}
\note{
Background tutorials can be stopped from the current session with \code{learnr.dashboard::end_background_tutorial()}

Uses system calls which may not be platform independent.

To see the available tutorials for any package, run \code{learnr::available_tutorials()}
}
\examples{
learnr.dashboard::start_background_tutorial("fg1")

learnr.dashboard::start_background_tutorial("fg2")

learnr.dashboard::start_background_tutorial("fg3")
}
