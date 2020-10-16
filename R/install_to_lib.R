#' @export
install_to_lib <- function(pkg=".", libpath=.libPaths()[1]) {
  #' install package in libpath

  libpaths = .libPaths()
  set_lib_paths(libpath)

  # test tutorial package
  # devtools::check(pkg=pkg)

  devtools::install(
    pkg=pkg,
    dependencies=F
  )

  # # this was broken and had to be reinstalled
  # install.packages("stringi")
  # # missing packages
  # remotes::install_github("rstudio-education/gradethis")
  # devtools::install_github("lionel-/redpen")
  # devtools::install_github("dtkaplan/checkr")

  set_lib_paths(libpaths)

}
