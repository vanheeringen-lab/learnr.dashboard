#' Return path(s) to the system libraries
#' @keywords internal
#' @description
#' Checks if the libraries are available and usable.
#' Returns the paths to the libraries.
get_system_libs <- function(system_libs=NULL){
  # dev note:
  # Currently just returns .Library.site
  #
  # We stopped using the Renv sandbox and Conda
  # (due to issues with persistence and reproducibility respectively).
  #
  # As long as the regular system libraries stays clean
  # (same version, noting external installed)
  # this will suffice.

  if ( is.null(system_libs) ){
    # # use the renv-system-library if it exists
    # for (tmpdir in list.files("/tmp")){
    #   if ("renv-system-library" %in% list.files(paste0("/tmp/", tmpdir))){break}
    # }
    # system_libs = paste0("/tmp/", tmpdir, "/renv-system-library")
    #
    # # else use the conda system library if it exists
    # if (!dir.exists(system_libs)){
    #   system_libs = .libPaths()[grepl("conda", .libPaths(), fixed=T)]
    #   system_libs = system_libs[!grepl(renv_path_substring, system_libs, fixed=T)]
    # }
    #
    # # else use the default system libraries
    # if (length(system_libs) == 0){
    #   system_libs = .libPaths()[grepl("usr", .libPaths(), fixed=T)]
    #   system_libs = system_libs[!grepl(renv_path_substring, system_libs, fixed=T)]
    # }
    system_libs <- .Library.site
  }

  # check that the system libraries are in order
  for (lib in system_libs){
    if ( !dir.exists(lib) ){
      stop("Could not find ", lib, "\n",
           "  Did you make a typo?")
    }
    if ( !(file.access(lib, 4) == 0 && file.access(lib, 1) == 0) ){
      stop("Incorrect permissions to the system library ", lib, "\n",
           "  Please tell the admin to run 'chmod -R 755' on the system libraries")
    }
  }

  return(system_libs)
}
