.setup_dev_dashboard <- function(
  lib = "/home/siebrenf/git/edu/learnr.proto/renv/library/R-3.6/x86_64-pc-linux-gnu",
  pkg = "/home/siebrenf/git/edu/learnr.dashboard"
) {
  learnr.dashboard:::.install_to_lib(pkg = pkg, lib=lib)
  #tryCatch({detach("package:learnr.dashboard", unload=TRUE)},error=function(cond){invisible()})
  #library(learnr.dashboard)
}

.setup_dev_proto <- function(
  lib = "/home/siebrenf/git/edu/learnr.proto/renv/library/R-3.6/x86_64-pc-linux-gnu",
  pkg = "/home/siebrenf/git/edu/learnr.proto"
) {
  learnr.dashboard:::.install_to_lib(pkg = pkg, lib=lib)
  # tryCatch({detach("package:learnr.proto", unload=TRUE)},error=function(cond){invisible()})
  # library(learnr.proto)
}
