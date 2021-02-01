#' Set libraries required to run learnr tutorials
#' @keywords internal
#' @description
#' Assert that a renv library is available.
#' Sets the renv library and system libraries for the session.
#' @note
#' Also preloads shiny and learnr, smoothing \code{start_background_tutorials()} by reducing the log.
set_tutorial_libraries <- function(renv_lib=NULL, system_libs=NULL){
  renv_lib <- get_renv_lib(renv_lib)
  system_libs <- get_system_libs(system_libs)

  # set libraries
  learnr.dashboard:::set_lib_paths(c(renv_lib, system_libs))

  # continue silently
  suppressMessages(
    invisible({

      # unload all packages (prevents mixing the libraries)
      lapply(names(sessionInfo()$loadedOnly), require, character.only = TRUE)
      lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE, force=TRUE)

      # load standard libraries to smooth out app loading
      lapply(c("shiny", "learnr"), library, character.only = TRUE)

    })
  )
}
