#' @export
start_tutorial <- function(name = "test", package = "learnr.proto") {
  #' start tutorial from package as tutorial
  learnr::run_tutorial(name, package = package)
}

#' @export
start_background_tutorial <- function(name = "test", package = "learnr.proto", rpath = NULL, r_args = NULL, logfile = NULL, port = NULL) {
  #' start tutorial from package in library as a background process.
  #' the tutorial should contain an inbuilt terminate on session end/timeout.

  libpaths = learnr.dashboard::learnr_setup(load=F)  # check if a renv library is available
  renv_lib = paste0("'", libpaths[1], "'")

  if ( is.null(rpath) ){
    rpath <- file.path(R.home(), "bin", "R")  # same as Rstudio server uses
  }

  if ( is.null(r_args) ){
    r_args = "--vanilla -q"  # cannot contain '-e'
  }

  # stores sdterr (app loaded/crashed messages)
  if ( is.null(logfile) ){
    logfile <- tempfile("learnr_log_", tempdir(check=T))
  }

  shiny_args = "list(launch.browser=FALSE)"
  if ( !is.null(port) ){
    shiny_args = paste0(
      "list(launch.browser=FALSE, port=", port, ")"
    )
  }

  # start the app via a background system call
  cmd = paste0(
    rpath, " ", r_args, " -e \"",
      ".libPaths(", renv_lib,")",
      "; ",
      "learnr.dashboard::learnr_setup()",
      "; ",
      "learnr::run_tutorial('", name, "', '", package, "', shiny_args=", shiny_args, ")",
      "; ",
      "q('no')",  # stop this R process after the tutorial has stopped
    "\" 2> ", logfile , " 1> /dev/null"
  )
  system(cmd, wait=FALSE)
  learnr.dashboard:::.open_browser(name, logfile)
}

.open_browser <- function(name, logfile, address="http://127.0.0.1") {
  #' start a browser when the app has loaded

  cat("Loading ", name, "..")
  log_lines_parsed = 0
  still_loading = TRUE
  app_online = FALSE
  while(TRUE){
    Sys.sleep(1)

    log = readLines(logfile, skipNul=TRUE)
    log = log[sapply(log, nchar) > 0]  # remove empty lines
    len = length(log)

    if ( still_loading && len == 0 ) {
      cat(".")  # indicate that app is still loading
    } else if ( still_loading && len > 0 ){
      cat('\n\n')  # add newline before starting to print the log
      still_loading = FALSE
    } else if ( len > log_lines_parsed ){
      for (line in log[log_lines_parsed+1: len]){
        cat(line, "\n")

        if ( startsWith(line, "Listening on ") ){
          port = strsplit(line, ":", fixed=TRUE)[[1]][3]
          app_online = TRUE
          break  # break from for loop
        }

        if ( line == "Execution halted" ){
          stop("An error had occured!")
        }
      }
      log_lines_parsed <- len

      if ( app_online ){
        url = paste0(address, ":", port)
        browseURL(url)
        break  # break from while loop
      }
    }
  }
  unlink(logfile)
}
