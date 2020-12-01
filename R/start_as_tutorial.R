#' @export
start_tutorial <- function(name = "test", package = "learnr.proto") {
  #' start tutorial from package as tutorial
  learnr::run_tutorial(name, package = package)
}

#' @export
start_background_tutorial <- function(name = "test", package = "learnr.proto", rpath = "/home/siebrenf/miniconda3/envs/learnr/bin/R", libpath = "/home/siebrenf/miniconda3/envs/learnr/lib/R/library", port = 8686) {
  #' start tutorial from package in library as a background process.
  #' the called process should contain an inbuilt terminate on session end.

  # start the app via a background system call
  cmd_start <- paste0(rpath, " -e \"")
  set_library <- paste0("learnr.dashboard::set_lib_paths(\'", libpath, "\')")
  cmd_next <- "; "
  set_tutorial <- paste0("learnr::run_tutorial(\'", name, "\', \'", package, "\', shiny_args = list(launch.browser = FALSE, port=", port, "))")
  cmd_end <- "\""

  cmd = paste0(cmd_start, set_library, cmd_next, set_tutorial, cmd_end)
  system(cmd, wait = FALSE)

  # give the server some time to boot up
  Sys.sleep(2.5)

  # open the browser window to the app
  url = paste0("http://127.0.0.1:", port)
  browseURL(url)
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

#' @export
update_dev_tutorial <- function(dev_path = "/home/siebrenf/git/edu/learnr.proto") {

  # update the tutorial
  devtools::install(
    pkg=dev_path,
    dependencies=F,
    build_vignettes=F,
    quiet=T,
    force=F
  )

}
