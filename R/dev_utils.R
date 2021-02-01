#' @title Install learnr.dashboard from project folder
#' @keywords internal
#' @description just a convenient wrapper
#' @examples learnr.dashboard:::.setup_learnr_dashboard()
.setup_learnr_dashboard <- function(
  lib = NULL,
  pkg = "/home/siebrenf/git/edu/learnr.dashboard"
) {
  if (is.null(pkg)) pkg <- getwd()
  if (is.null(lib)) lib <- .libPaths()[1]

  if (!grepl(file.path("renv", "library"), lib, fixed=T)) stop("Function must be run in an active renv project.\n  Active lib: ", lib)

  learnr.dashboard:::install_to_lib(pkg = pkg, lib=lib)
  #tryCatch({detach("package:learnr.dashboard", unload=TRUE)},error=function(cond){invisible()})
  #library(learnr.dashboard)
}

#' @title Install learnr.proto from project folder
#' @keywords internal
#' @description just a convenient wrapper
#' @examples learnr.dashboard:::.setup_learnr_proto()
.setup_learnr_proto <- function(
  lib = NULL,
  pkg = "/home/siebrenf/git/edu/learnr.proto"
) {
  if (is.null(pkg)) pkg <- getwd()
  if (is.null(lib)) lib <- .libPaths()[1]

  if (!grepl(file.path("renv", "library"), lib, fixed=T)) stop("Function must be run in an active renv project.\n  Active lib: ", lib)

  learnr.dashboard:::install_to_lib(pkg = pkg, lib=lib)
  # tryCatch({detach("package:learnr.proto", unload=TRUE)},error=function(cond){invisible()})
  # library(learnr.proto)
}

#' @title start tutorial in development as shiny markdown
#' @keywords internal
#' @description works without reinstalling the package first
#' @examples learnr.dashboard:::.start_dev_app("fg1")
.start_dev_app <- function(name="test", tutorial_dir="/home/siebrenf/git/edu/learnr.proto/inst/tutorials") {
  tutorial_path = file.path(tutorial_dir, name)

  # Doesn't always start if the html exists.
  # (this may causes issues with multiple users)
  rmarkdown::shiny_prerendered_clean(tutorial_path)

  # start shiny app from code here
  rmarkdown::run(
    file = NULL,
    dir = tutorial_path,
    # shiny_args = list(launch.browser = TRUE)
    shiny_args = list(
      launch.browser = (interactive() || identical(Sys.getenv("LEARNR_INTERACTIVE", "0"), "1"))
    )
  )

}
