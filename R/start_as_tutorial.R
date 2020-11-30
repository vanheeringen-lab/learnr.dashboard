#' @export
start_tutorial <- function(name = "test", package = "learnr.proto") {
  #' start tutorial from package as tutorial
  learnr::run_tutorial(name, package = package)
}

#' @export
start_dev_tutorial <- function(
  lesson = "test",
  dev_path = "/home/siebrenf/git/edu/learnr.proto",
  install_lib_path = "/home/siebrenf/miniconda3/envs/learnr/lib/R/library"
  ) {
  #' dev only
  #' reinstall pkg in dev_path to install_lib_path
  #' then run lesson as tutorial

  original_libpaths <- .libPaths()
  learnr.dashboard::set_lib_paths(install_lib_path)

  # update the tutorial
  devtools::install(
    pkg=dev_path,
    dependencies=F,
    build_vignettes=F,
    quiet=T,
    force=F
  )

  learnr.dashboard::set_lib_paths(original_libpaths)

  # run as tutorial
  learnr::run_tutorial(lesson, package = basename(dev_path))

}
