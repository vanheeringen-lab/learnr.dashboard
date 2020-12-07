#' @export
install_to_lib <- function(pkg=NULL, libpaths=NULL) {
  #' install package in libpaths
  #' example install_to_lib("/home/siebrenf/git/edu/learnr.dashboard")

  if ( is.null(pkg) ) {pkg <- getwd()}

  original_libpaths = .libPaths()
  if ( !is.null(libpaths) ) {learnr.dashboard::set_lib_paths(libpaths)}

  devtools::install(
    pkg=pkg,
    dependencies=F,
    build_vignettes=F,
    force=F
  )

  if ( !identical(original_libpaths, .libPaths()) ){learnr.dashboard::set_lib_paths(original_libpaths)}

}
