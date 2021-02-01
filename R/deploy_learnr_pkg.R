#' Install learnr tutorials
#'
#' @description
#' Run this function from the base of the package project directory, with renv active (or set the arguments). Will perform the following actions:
#'
#' 1. git pull
#'
#' 2. update the renv library
#'
#' 3. install \code{pkg} in \code{lib}.
#'
#' 4. regenerate the HTML files for the listed \code{tutorials}
#'
#' 5. make the renv library accessible to all users with \code{chmod -R 755}
#'
#' 6. make the path up to the renv library accessible with \code{chmod 755}
#'
#' @note
#' Uses system calls which may not be platform independent.
#'
#' If you get an \code{error in .validate_signal_args}, try restarting the R session and run again.
#'
#' @param tutorials List of tutorials to update. Default: all tutorials in the tutorials directory
#' @param pkg Tutorial package. Default: current directory
#' @param lib Library to install pkg. Default: library 1 (the renv library if activated)
#' @examples
#' learnr.dashboard:::setup_learnr_pkg("fg3")
#'
#' learnr.dashboard:::setup_learnr_pkg(c("fg1", "fg2"))
deploy_learnr_pkg <- function(tutorials=NULL, pkg=NULL, lib=NULL){
  if (is.null(pkg)) pkg <- getwd()
  if (is.null(lib)) lib <- .libPaths()[1]

  if (!grepl(file.path("renv", "library"), lib, fixed=T)) stop("Function must be run in an active renv project.\n  Active lib: ", lib)

  # git pull
  curr_dir <- getwd()
  setwd(pkg)
  system("git pull")
  setwd(curr_dir)

  # update renv
  renv::restore(prompt=F)

  # install the tutorials
  learnr.dashboard:::install_to_lib(pkg = pkg, lib=lib)

  pkg_name = base::basename(pkg)
  base_path = file.path(lib, pkg_name, "tutorials")
  if (is.null(tutorials)) tutorials <- list.files(file.path(pkg, "inst", "tutorials"))
  #if (is.null(tutorials)) tutorials <- learnr::available_tutorials(pkg_name)[[2]]
  for (tutorial in tutorials){
    # remove the tutorial html file
    html_path = file.path(base_path, tutorial, paste0(tutorial, ".html"))
    if (file.exists(html_path)) system(paste0("rm -rf ", html_path), wait=T)  # file.remove(html_path)

    # regenerate the tutorial html file
    learnr.dashboard::start_background_tutorial(tutorial)
  }
  Sys.sleep(3)
  learnr.dashboard::end_background_tutorial()

  # set permission to the renv library
  system(paste0("chmod -R 755 ", lib), wait=T)  # Sys.chmod() is not recursive

  # set permission to the path leading up to the renv library
  all_dirs = strsplit(lib, "/", fixed=T)[[1]]
  dir_lvl=file.path("")
  for ( dir in all_dirs[2:length(all_dirs)] ){
    system(paste0("chmod 755 ", dir_lvl), wait=T, ignore.stderr=T)
  }
}

# learnr.dashboard:::setup_learnr_pkg(c("fg3"))
