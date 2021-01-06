.setup_dev_dashboard <- function(
  lib = NULL,
  pkg = "/home/siebrenf/git/edu/learnr.dashboard"
) {
  learnr.dashboard:::.install_to_lib(pkg = pkg)
  #tryCatch({detach("package:learnr.dashboard", unload=TRUE)},error=function(cond){invisible()})
  #library(learnr.dashboard)
}

.setup_dev_proto <- function(
  lib = NULL,
  pkg = "/home/siebrenf/git/edu/learnr.proto"
) {
  learnr.dashboard:::.install_to_lib(pkg = pkg)
  # tryCatch({detach("package:learnr.proto", unload=TRUE)},error=function(cond){invisible()})
  # library(learnr.proto)
}
