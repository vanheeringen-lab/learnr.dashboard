#' @title install package from project folder to lib
#' @keywords internal
#' @examples learnr.dashboard:::install_to_lib("/home/siebrenf/git/edu/learnr.dashboard")
install_to_lib <- function(pkg=NULL, lib=NULL) {
  if ( is.null(pkg) ) {pkg <- getwd()}
  if ( is.null(lib) ) {lib <- .libPaths()[1]}
  suppressWarnings(
    devtools::install(
      pkg=pkg,
      dependencies=F,  # Do not update packages here. Renv should do this
      build_vignettes=F,
      force=F,
      lib=lib
    )
  )
}
