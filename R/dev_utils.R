#   learnr.dashboard::set_lib_paths("/home/siebrenf/miniconda3/envs/learnr/lib/R/library"); library(learnr.dashboard); library(learnr.proto)

setup_dev_dashboard <- function(
  libpaths = NULL,
  pkg = "/home/siebrenf/git/edu/learnr.dashboard"
) {
  if ( !is.null(libpaths) ) {learnr.dashboard::set_lib_paths(libpaths)}
  learnr.dashboard::install_to_lib(pkg = pkg)

  tryCatch(
    {detach("package:learnr.dashboard", unload=TRUE)},
    error=function(cond) {}
  )
  library(learnr.dashboard)
}

setup_dev_proto <- function(
  libpaths = NULL,
  pkg = "/home/siebrenf/git/edu/learnr.proto"
) {
  if ( !is.null(libpaths) ) {learnr.dashboard::set_lib_paths(libpaths)}
  learnr.dashboard::install_to_lib(pkg = pkg)

  tryCatch(
    {detach("package:learnr.proto", unload=TRUE)},
    error=function(cond) {}
  )
  library(learnr.proto)
}

# setup_conda_env <- function(
#   env_name = NULL,
#   env_path = "/home/siebrenf/git/edu/learnr.proto/inst/conda/environment.yaml",
#   force = TRUE,
#   conda_path = "/home/siebrenf/miniconda3/bin/mamba"
# ) {
#   if (is.null(env_name)){return("must specify env_name")}
#
#   if (force) {
#     cmd <- paste0(conda_path, " env list | grep ", env_name)
#     suppressWarnings({
#       envs <- system(cmd, intern = TRUE)[1]
#     })
#
#     if (!is.na(envs)) {
#       env_path_to_rm <- strsplit(envs, " ")
#       env_path_to_rm <- env_path_to_rm[[1]][length(env_path_to_rm[[1]])]
#       cmd <- paste0("rm -rf ", env_path_to_rm)
#       system(cmd)
#     }
#   }
#
#   cmd = paste0(conda_path, " env create -n ", env_name, " -f ", env_path)
#   system(cmd)
#
#   cmd <- paste0(conda_path, " env list | grep ", env_name)
#   env <- system(cmd, intern = TRUE)[1]
#   env_path_to_return <- strsplit(env, " ")
#   env_path_to_return <- env_path_to_return[[1]][length(env_path_to_return[[1]])]
#   return( paste0(env_path_to_return, "/lib/R/library") )
# }
