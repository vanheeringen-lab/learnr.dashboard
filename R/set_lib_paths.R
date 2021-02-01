#' @title actually set R library paths
#' @keywords internal
#' @description R has no formal method to set library paths. Only Renv and this function seem to be able to do this.
#' @param lib_vec library path(s) to use
#' @details source: https://www.milesmcbain.com/posts/hacking-r-library-paths/
set_lib_paths <- function(lib_vec) {
  lib_vec <- normalizePath(lib_vec, mustWork = TRUE)

  shim_fun <- .libPaths
  shim_env <- new.env(parent = environment(shim_fun))
  shim_env$.Library <- character()
  shim_env$.Library.site <- character()

  environment(shim_fun) <- shim_env
  shim_fun(lib_vec)

}
