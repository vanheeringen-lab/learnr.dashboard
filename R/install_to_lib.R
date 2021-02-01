#' @keywords internal
.install_to_lib <- function(pkg=NULL, lib=NULL) {
  #' install package in lib
  #' example: .install_to_lib("/home/siebrenf/git/edu/learnr.dashboard")

  if ( is.null(pkg) ) {pkg <- getwd()}
  if ( is.null(lib) ) {lib <- .libPaths()[1]}
  suppressWarnings(
    devtools::install(
      pkg=pkg,
      dependencies=F,
      build_vignettes=F,
      force=F,
      lib=lib
    )
  )
}
