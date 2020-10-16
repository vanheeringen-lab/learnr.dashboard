# learnr.dashboard::set_lib_paths("/home/siebrenf/miniconda3/envs/learnr/lib/R/library"); library(learnr.dashboard)

setup_dashboard <- function() {
  pkg = "/home/siebrenf/git/edu/learnr.dashboard"
  libpath = "/home/siebrenf/miniconda3/envs/learnr/lib/R/library"

  set_lib_paths(libpath)
  install_to_lib(pkg, libpath)

}

setup_proto <- function() {
  pkg = "/home/siebrenf/git/edu/learnr.proto"
  libpath = "/home/siebrenf/miniconda3/envs/learnr/lib/R/library"

  set_lib_paths(libpath)
  install_to_lib(pkg, libpath)

}

edit_proto <- function() {
  pkg = "/home/siebrenf/git/edu/learnr.proto"
  tutorial = "inst/tutorials/test/test.Rmd"
  path = file.path(pkg, tutorial)
  file.edit(path)

}

# doesnt work: not interactive
# run_proto <- function() {
#   pkg = "/home/siebrenf/git/edu/learnr.proto"
#   tutorial = "inst/tutorials/test/test.Rmd"
#   path = file.path(pkg, tutorial)
#   rmarkdown::run(path)
# }
