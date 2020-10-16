#' @export
start_tutorial <- function(lesson = "test", pkg = "learnr.proto") {
  #' start lesson from pkg as tutorial
  learnr::run_tutorial(lesson, package = pkg)
}

#' @export
dev.t <- function() {
  #' dev only
  #' update lesson and run as tutorial

  libpath = "/home/siebrenf/miniconda3/envs/learnr/lib/R/library"
  pkg = "/home/siebrenf/git/edu/learnr.proto"

  set_lib_paths(libpath)

  # update the tutorial
  devtools::install(
    pkg=pkg,
    dependencies=F,
    build_vignettes=F,
    quiet=T,
    force=F
  )

  # run prototype tutorial
  learnr::run_tutorial("test", package = "learnr.proto")

}
