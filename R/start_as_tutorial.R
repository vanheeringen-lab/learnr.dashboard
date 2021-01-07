#' @export
start_tutorial <- function(name, package = "learnr.proto") {
  #' start tutorial from package as tutorial
  learnr.dashboard:::.run_tutorial(name, package = package)
}

#' @export
end_background_tutorial <- function(...){
  #' kill all (your) running background tutorials
  cmd = "kill $(ps aux | grep [l]earnr.dashboard:::.run_tutorial | awk '{print $1, $2}' | grep $(whoami) | awk '{print $2}')"
  system(cmd, wait=FALSE)
}

#' @export
start_background_tutorial <- function(name, package = "learnr.proto", r_path = NULL, r_args = NULL, port = NULL) {
  #' start tutorial from package in library as a background process.
  #' the tutorial should contain an inbuilt terminate on session end/timeout.

  # check if a renv library is available
  libpaths = learnr.dashboard:::.learnr_setup(load=F)
  renv_lib = paste0("'", libpaths[1], "'")

  # stores sdterr (app loaded/crashed messages)
  logfile <- tempfile("learnr_log_", tempdir(check=T))

  if ( is.null(r_path) ){
    r_path <- file.path(R.home(), "bin", "R")  # same as Rstudio server uses
  }

  if ( is.null(r_args) ){
    r_args = "--vanilla -q"  # cannot contain '-e'
  }

  shiny_args = "list(launch.browser=FALSE)"
  if ( !is.null(port) ){
    shiny_args = paste0(
      "list(launch.browser=FALSE, port=", port, ")"
    )
  }

  # start the app via a background system call
  cmd = paste0(
    r_path, " ", r_args, " -e \"",
      ".libPaths(", renv_lib,")",
      "; ",
      "learnr.dashboard:::.learnr_setup()",
      "; ",
      "learnr.dashboard:::.run_tutorial('", name, "', '", package, "', shiny_args=", shiny_args, ")",
      "; ",
      "q('no')",  # stop this R process after the tutorial has stopped
    "\" 2> ", logfile , " 1> /dev/null"
  )
  system(cmd, wait=FALSE)
  learnr.dashboard:::.open_browser(name, logfile)
}

.run_tutorial <- function (name = NULL, package = NULL, shiny_args = NULL)
{
  #' re-implementation of learnr::run_tutorial.
  #' ~~if the tutorial html file exists, learnr does not need to write anything.~~
  #' ~~this version skips the write permission check if not required.~~
  #' this version just removes the message.

  if (is.null(package) && !is.null(name)) {
    stop.("`package` must be provided if `name` is provided.")
  }
  tutorials <- learnr::available_tutorials(package = package)
  if (is.null(name)) {
    message(format(tutorials))
    return(invisible(tutorials))
  }
  tutorial_path <- learnr:::get_tutorial_path(name, package)
  learnr:::install_tutorial_dependencies(tutorial_path)
  if (is.null(shiny_args))
    shiny_args <- list()
  if (is.null(shiny_args$launch.browser)) {
    shiny_args$launch.browser <- (interactive() || identical(Sys.getenv("LEARNR_INTERACTIVE",
                                                                        "0"), "1"))
  }
  render_args <- tryCatch({
    local({
      # if(!file.exists(file.path(tutorial_path, paste0(name, ".html")))){
        tmp_save_file <- file.path(tutorial_path, "__leanr_test_file")
        on.exit({
          if (file.exists(tmp_save_file)) {
            unlink(tmp_save_file)
          }
        }, add = TRUE)
        suppressWarnings(cat("test", file = tmp_save_file))
      # }
      list()
    })
  }, error = function(e) {
    # message("Rendering tutorial in a temp folder since `learnr` does not have write permissions in the tutorial folder: ",
    #         tutorial_path)
    temp_output_dir <- file.path(tempdir(), "learnr", package,
                                 name)
    if (!dir.exists(temp_output_dir)) {
      dir.create(temp_output_dir, recursive = TRUE)
    }
    list(output_dir = temp_output_dir, intermediates_dir = temp_output_dir,
         knit_root_dir = temp_output_dir)
  })
  withr::with_dir(tutorial_path, {
    if (!identical(Sys.getenv("SHINY_PORT", ""), "")) {
      withr::local_envvar(c(RMARKDOWN_RUN_PRERENDER = "0"))
    }
    rmarkdown::run(file = NULL, dir = tutorial_path, shiny_args = shiny_args,
                   render_args = render_args)
  })
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
        if ( is.na(line) ) next  # skip NAs
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
