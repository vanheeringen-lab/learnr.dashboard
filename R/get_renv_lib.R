#' Return path to the renv library
#' @keywords internal
#' @description
#' Check if exactly one renv library is available, and if the library is usable.
#' Returns the path to the library.
get_renv_lib <- function(renv_lib=NULL){
  # find renv library in current library paths
  if ( is.null(renv_lib) ){
    renv_path_substring <- file.path("renv", "library")
    renv_lib <- .libPaths()[grepl(renv_path_substring, .libPaths(), fixed=T)]
  }

  # check that the renv library is in order
  if ( length(renv_lib)<1 ){
    stop("No renv library found!\n",
         "  Add one with .libPaths('/path/to/renv/library')")
  }
  if ( length(renv_lib)>1 ){
    stop("More than one renv library found!\n",
         "  Please restart R with .rs.restartR() ",
         "and add one with .libPaths('/path/to/renv/library')")
  }
  if ( !dir.exists(renv_lib) ){
    stop("Could not find ", renv_lib, "\n",
         "  Did you make a typo?")
  }
  if ( !(file.access(renv_lib, 4) == 0 && file.access(renv_lib, 1) == 0) ){
    stop("Incorrect permissions to renv library ", renv_lib,"\n",
         "  Please tell the admin to run 'chmod -R 755' on the renv library, ",
         "the renv library cache, and any protected upstream directories.")
  }

  return(renv_lib)
}
