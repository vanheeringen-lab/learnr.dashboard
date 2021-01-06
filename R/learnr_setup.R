.learnr_setup <- function(renv_lib=NULL, system_libs=NULL, load=TRUE){
  #' Assert that a renv library is available.
  #' If load=TRUE, set the renv library and system libraries as only libraries.
  #' If load=FALSE, return the renv library and system libraries.
  #' Uses the renv system library if available, else use the default system libraries.

  # find renv library in library paths
  if ( is.null(renv_lib) ){
    renv_path_substring <- file.path("renv", "library")
    renv_lib <- .libPaths()[grepl(renv_path_substring, .libPaths(), fixed=T)]
  }
  if ( length(renv_lib)<1 ){
    stop("No renv library found! Add one with .libPaths('/path/to/renv/library')")
  }
  if ( length(renv_lib)>1 ){
    stop("More than one renv library found! Please restart R with .rs.restartR()")
  }
  if ( !(file.access(renv_lib, 4) == 0 && file.access(renv_lib, 1) == 0) ){
    stop("Incorrect permissions to renv library!
         Please tell the admin to run 'chmod -R 755' on the renv library and upstream protected directories.")
  }

  # find the system libraries
  if ( is.null(system_libs) ){
    # check for a renv-system-library
    for (tmpdir in list.files("/tmp")){
      if ("renv-system-library" %in% list.files(paste0("/tmp/", tmpdir))){break}
    }
    system_libs = paste0("/tmp/", tmpdir, "/renv-system-library")

    # use the default system libraries if renv-system-library does not exist
    if (!dir.exists(system_libs)){
      system_libs = .libPaths()[grepl("usr", .libPaths(), fixed=T)]
    }
  }

  if (load){
    # set libraries
    learnr.dashboard:::.set_lib_paths(c(renv_lib, system_libs))

    # unload all packages (prevents mixing the libraries)
    suppressPackageStartupMessages(invisible(lapply(names(sessionInfo()$loadedOnly), require, character.only = TRUE)))
    suppressWarnings(invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE, force=TRUE)))
  } else {
    return(c(renv_lib, system_libs))
  }
}
