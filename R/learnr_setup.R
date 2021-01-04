#' @export
learnr_setup <- function(renv_lib, system_libs=NULL){
  #' switch library paths to the renv libraries.
  #' renv installs new packages in a dedicated renv_lib.
  #' renv symlinks the base system libraries in a dir in /tmp (with 755 permissions)
  #' this folder is required, but can be found automatically if it exists.
  #' If it does not exist, the system libraries are used directly.

  if ( is.null(system_libs) ){
    # find the renv-system-library
    for (tmpdir in list.files("/tmp")){
      if ("renv-system-library" %in% list.files(paste0("/tmp/", tmpdir))){break}
    }
    system_libs = paste0("/tmp/", tmpdir, "/renv-system-library")

    # use raw system libraries if renv-system-library does not exist
    if (!dir.exists(renv_sys_lib)){system_libs = .libPaths()[grepl("usr", .libPaths(), fixed=T)]}
  }

  # set libraries
  learnr.dashboard::set_lib_paths(c(renv_lib, system_libs))

  # unload all packages (prevents mixing the libraries)
  suppressPackageStartupMessages(invisible(lapply(names(sessionInfo()$loadedOnly), require, character.only = TRUE)))
  suppressWarnings(invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE, force=TRUE)))
}
