# #' @export
# install_to_lib <- function(pkg=".", libpath=NULL) {
#   #' install package in libpath
#
#   original_libpaths = .libPaths()
#
#   if ( !is.null(libpath) ){
#     .libPaths(c(libpath, .libPaths()))
#   }
#
#   #original_libpaths = .libPaths()
#   # learnr.dashboard::set_lib_paths(libpath)
#
#   # test tutorial package
#   # devtools::check(pkg=pkg)
#
#   devtools::install(
#     pkg=pkg,
#     dependencies=F
#   )
#
#   # # this was broken and had to be reinstalled
#   # install.packages("stringi")
#   # # missing packages
#   # remotes::install_github("rstudio-education/gradethis")
#   # devtools::install_github("lionel-/redpen")
#   # devtools::install_github("dtkaplan/checkr")
#
#   learnr.dashboard::set_lib_paths(original_libpaths)
#
# }
