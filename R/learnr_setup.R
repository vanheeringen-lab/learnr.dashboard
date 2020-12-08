#' @export
learnr_setup <- function(renv_lib, renv_sys_lib=NULL){
  #' switch library paths to the renv libraries.
  #' renv installs new packages in a dedicated renv_lib.
  #' renv symlinks the base system libraries in a dir in /tmp (with 755 permissions)
  #' this folder is required, but can be found automatically if it exists.

  if ( is.null(renv_sys_lib) ){
    # find the renv-system-library
    for (tmpdir in list.files("/tmp")){
      if ("renv-system-library" %in% list.files(paste0("/tmp/", tmpdir))){break}
    }
    renv_sys_lib = paste0("/tmp/", tmpdir, "/renv-system-library")
    if (!dir.exists(renv_sys_lib)){stop("renv-system-library not found!")}
  }

  # load the minimal libraries
  learnr.dashboard::set_lib_paths(c(renv_lib, renv_sys_lib))

  # unload all packages (prevents mixing the libraries)
  suppressPackageStartupMessages(invisible(lapply(names(sessionInfo()$loadedOnly), require, character.only = TRUE)))
  suppressWarnings(invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE, force=TRUE)))
}
