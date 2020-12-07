#' @export
start_tutorial <- function(name = "test", package = "learnr.proto") {
  #' start tutorial from package as tutorial
  learnr::run_tutorial(name, package = package)
}

#' @export
start_background_tutorial <- function(name = "test", package = "learnr.proto", libpaths = NULL, rpath = NULL, r_flags = NULL, logfile = NULL, port = NULL) {
  #' start tutorial from package in library as a background process.
  #' the called process should contain an inbuilt terminate on session end.

  if ( is.null(libpaths) ){
    libpaths = .libPaths()
  }
  if ( !all(grepl("renv", libpaths, fixed=T)) ){
    stop("The libpaths must contain the renv project library.")
  }

  if ( is.null(rpath) ){
    rpath <- "R"
  }

  if ( is.null(r_flags) ){
    r_flags = "--vanilla -q"
  }

  if ( is.null(logfile) ){
    logfile <- tempfile(
      pattern = "learnr_log_",
      tmpdir = tempdir(check=T)
    )
  }

  shiny_args = "list(launch.browser = FALSE)"
  if ( !is.null(port) ){
    shiny_args = paste0(
      "list(launch.browser=FALSE, port=", port, ")"
    )
  }

  # start the app via a background system call
  cmd = paste0(
    rpath, " ", r_flags, " -e \"",
      "learnr.dashboard::set_lib_paths(c('", libpaths[1], "', '", libpaths[2], "'))",
      "; ",
      "learnr::run_tutorial('", name, "', '", package, "', shiny_args = ", shiny_args, ")",
    "\" 2> ", logfile , " 1> /dev/null"
  )
  # # the bash command as it would run for me:
  # cmd = paste0(
  #   "R --vanilla -q -e \"",
  #     "learnr.dashboard::set_lib_paths(c('/home/siebrenf/git/edu/learnr.proto/renv/library/R-3.6/x86_64-pc-linux-gnu', '/tmp/Rtmp87oD66/renv-system-library'));",
  #     "learnr::run_tutorial('test', 'learnr.proto', shiny_args = list(launch.browser = FALSE))",
  #   "\" 2> ~/learnr.log 1> /dev/null"
  # )
  system(cmd, wait = FALSE)

  # start the browser when the app has loaded
  # the log will contain "Listening on ..." (and the port used).
  log_lines_parsed = 0
  cat("Loading ", name, "..")
  still_loading = T
  app_online = FALSE
  while(TRUE){
    Sys.sleep(1)

    log = readLines(logfile, skipNul=T)
    log = log[sapply(log, nchar) > 0]  # remove empty lines
    len = length(log)

    # add newline before starting to print the log
    if (still_loading && len == 0) {
      cat(".")
    } else if (still_loading && len > 0 ){
      cat('\n\n')
      still_loading = F
    } else if ( len > log_lines_parsed ){
      for (line in log[log_lines_parsed: len]){
        cat(line, "\n")

        if ( startsWith(line, "Listening on ") ){
          # get port if not specified
          if ( is.null(port) ){
            port = strsplit(line, ":", fixed = T)[[1]][3]
          }
          app_online = TRUE
          break  # break from for loop
        }

        if (line == "Execution halted"){
          stop("An error had occured!")
        }
      }
      log_lines_parsed <- len + 1

      if (app_online){
        url = paste0("http://127.0.0.1:", port)
        browseURL(url)
        break  # break from while loop
      }
    }
  }

  unlink(logfile)
}

# #' @export
# start_background_tutorial <- function(name = "test", package = "learnr.proto", libpath = NULL, rpath = NULL, port = 8686) {
#   #' start tutorial from package in library as a background process.
#   #' the called process should contain an inbuilt terminate on session end.
#
#   if ( is.null(libpath) ){
#     libpath = .libPaths()[1]  # libpath = "/home/siebrenf/miniconda3/envs/learnr/lib/R/library"
#   }
#   if ( is.null(rpath) ){
#     # dirs <- strsplit(libpath, "/")[[1]]
#     # l <- length(dirs)-3
#     # new_dirs <- do.call(c, list(dirs[1:l], list("bin", "R")))
#     # rpath <- paste(new_dirs, collapse = '/')
#     rpath <- "R"  # system R
#   }
#
#   # start the app via a background system call
#   cmd_start <- paste0(rpath, " -e \"")
#   set_library <- paste0("learnr.dashboard::set_lib_paths(\'", libpath, "\')")
#   cmd_next <- "; "
#   set_tutorial <- paste0("learnr::run_tutorial(\'", name, "\', \'", package, "\', shiny_args = list(launch.browser = FALSE, port=", port, "))")
#   cmd_end <- "\""
#
#   cmd = paste0(cmd_start, set_library, cmd_next, set_tutorial, cmd_end)
#   system(cmd, wait = FALSE)
#
#   # give the server some time to boot up
#   Sys.sleep(2.5)
#
#   # open the browser window to the app
#   url = paste0("http://127.0.0.1:", port)
#   browseURL(url)
# }

# #' @export
# start_dev_tutorial <- function(
#   lesson = "test",
#   dev_path = "/home/siebrenf/git/edu/learnr.proto",
#   install_lib_path = "/home/siebrenf/miniconda3/envs/learnr/lib/R/library"
#   ) {
#   #' dev only
#   #' reinstall pkg in dev_path to install_lib_path
#   #' then run lesson as tutorial
#
#   learnr.dashboard::install_to_lib(
#     pkg = dev_path,
#     quick = T,
#     libpath = install_lib_path
#   )
#
#   # run as tutorial
#   learnr::run_tutorial(lesson, package = basename(dev_path))
#
# }

# #' @export
# update_dev_tutorial <- function(
#   dev_path = "/home/siebrenf/git/edu/learnr.proto",
#   libpath = NULL
#   ) {
#
#   original_libpaths = .libPaths()
#   if (is.null(libpath)) {libpath = .libPaths()[1]}
#
#   learnr.dashboard::set_lib_paths(libpath)
#   # update the tutorial
#   devtools::install(
#     pkg=dev_path,
#     dependencies=F,
#     build_vignettes=F,
#     quiet=T,
#     force=F
#   )
#
#   learnr.dashboard::set_lib_paths(original_libpaths)
#
# }
