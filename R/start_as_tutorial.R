#' Start a learnr tutorial
#'
#' @param name Tutorial name. Available tutorials: "fg1", "fg2", "fg3", "fg4".
#' @param package Tutorial package. Default: learnr.proto (Functional Genomics)
#' @param host Rstudio Server IP address. Required if the server is not hosting on localhost. Automatically set for rstudio.science.ru.nl.
#' @examples
#' learnr.dashboard::start_tutorial("fg1")
#'
#' learnr.dashboard::start_tutorial("fg2")
#' @export
start_tutorial <- function(name, package = "learnr.proto", host = NULL) {
  if ( is.null(host) ){
    if ( Sys.info()["nodename"]=="rstudiovm" ) host <- "131.174.16.139"
  }
  shiny_args = list()
  if ( !is.null(host) ){
    shiny_args = list("host"=host)
  }
  learnr.dashboard:::.run_tutorial(name, package = package, shiny_args=shiny_args)
}

#' Stop all background tutorials
#'
#' Stop all learnr tutorials you are running in the background. Progress should be saved.
#'
#' Uses system calls which may not be platform independent.
#'
#' @param ... Ignored.
#' @examples
#' learnr.dashboard::end_background_tutoria()
#'
#' learnr.dashboard::end_background_tutoria("fg1")
#' @export
end_background_tutorial <- function(...){
  cmd = "kill $(ps aux | grep [l]earnr.dashboard:::.run_tutorial | awk '{print $1, $2}' | grep $(whoami) | awk '{print $2}') > /dev/null 2>&1"
  system(cmd, wait=FALSE)
}

#' Start a learnr tutorial in the background
#'
#' Background tutorials do not occupy the current session
#'
#' Background tutorials should contain an inbuilt terminate on timeout,
#' but can be stopped immediately with `learnr.dashboard::end_background_tutorial()`
#'
#' Uses system calls which may not be platform independent.
#'
#' @param name Tutorial name. Available tutorials: "fg1", "fg2", "fg3", "fg4".
#' @param package Tutorial package. Default: learnr.proto (Functional Genomics)
#' @param r_path Specify the R executable to use. Default: Same as current session
#' @param r_args Specify the R flags to use. Default: --vanilla -q
#' @param host Rstudio Server IP address. Required if the server is not hosting on localhost. Automatically set for rstudio.science.ru.nl.
#' @param port Specify the port to start the tutorial app on (must be free). Default: NULL (picks a free port for you)
#' @examples
#' learnr.dashboard::start_background_tutorial("fg1")
#'
#' learnr.dashboard::start_background_tutorial("fg2")
#' @export
start_background_tutorial <- function(name, package = "learnr.proto", r_path = NULL, r_args = NULL, host = NULL, port = NULL) {
  #' start tutorial from package in library as a background process.
  #' the tutorial should contain an inbuilt terminate on session end/timeout.
  #' example: learnr.dashboard:::start_background_tutorial("fg1")

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

  shiny_args = "list(launch.browser=F)"
  if ( is.null(host) ){
    if ( Sys.info()["nodename"]=="rstudiovm" ) host <- "131.174.16.139"
  }
  if ( !is.null(host) ){
    shiny_args = paste0(
      substr(shiny_args, 1, nchar(shiny_args)-1),
      ", host='", host, "')"
    )
  }
  if ( !is.null(port) ){
    shiny_args = paste0(
      substr(shiny_args, 1, nchar(shiny_args)-1),
      ", port=", port, ")"
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
  # render_args <- tryCatch({
  #   local({
  #     # if(!file.exists(file.path(tutorial_path, paste0(name, ".html")))){
  #       tmp_save_file <- file.path(tutorial_path, "__leanr_test_file")
  #       on.exit({
  #         if (file.exists(tmp_save_file)) {
  #           unlink(tmp_save_file)
  #         }
  #       }, add = TRUE)
  #       suppressWarnings(cat("test", file = tmp_save_file))
  #     # }
  #     list()
  #   })
  # }, error = function(e) {
  #   # message("Rendering tutorial in a temp folder since `learnr` does not have write permissions in the tutorial folder: ",
  #   #         tutorial_path)
  #   temp_output_dir <- file.path(tempdir(), "learnr", package,
  #                                name)
  #   if (!dir.exists(temp_output_dir)) {
  #     dir.create(temp_output_dir, recursive = TRUE)
  #   }
  #   list(output_dir = temp_output_dir, intermediates_dir = temp_output_dir,
  #        knit_root_dir = temp_output_dir)
  # })
  render_args <- list()
  withr::with_dir(tutorial_path, {
    if (!identical(Sys.getenv("SHINY_PORT", ""), "")) {
      withr::local_envvar(c(RMARKDOWN_RUN_PRERENDER = "0"))
    }
    learnr.dashboard:::.run(file = NULL, dir = tutorial_path, shiny_args = shiny_args,
                            render_args = render_args)
  })
}

.run <- function (file = "index.Rmd", dir = dirname(file), default_file = NULL,
                  auto_reload = TRUE, shiny_args = NULL, render_args = NULL)
{
  #' re-implementation of rmarkdown::run.
  #' this version calls learnr.dashboard:::.runApp instead of shiny::runApp

  # import internal functions/objects
  # source: https://github.com/rstudio/rmarkdown/blob/master/R/util.R#L15
  "%||%" <- rmarkdown:::`%||%`
  # source: https://github.com/rstudio/shiny/blob/master/R/globals.R#L2
  .globals <- shiny:::.globals

  if (is.null(default_file)) {
    allRmds <- list.files(path = dir, pattern = "^[^_].*\\.[Rr][Mm][Dd]$")
    if (length(allRmds) == 1) {
      default_file <- allRmds
    }
    else {
      index <- which(tolower(allRmds) == "index.rmd")
      if (length(index) > 0) {
        default_file <- allRmds[index[1]]
      }
      else {
        for (rmd in allRmds) {
          runtime <- rmarkdown::yaml_front_matter(file.path(dir,
                                                            rmd))$runtime
          if (is_shiny(runtime)) {
            default_file <- rmd
            break
          }
        }
      }
    }
  }
  if (is.null(default_file)) {
    indexHtml <- list.files(dir, "index.html?", ignore.case = TRUE)
    if (length(indexHtml) > 0)
      default_file <- indexHtml[1]
  }
  dir <- rmarkdown:::normalize_path(dir)
  if (!rmarkdown:::dir_exists(dir))
    stop("The directory '", dir, "' does not exist")
  if (!is.null(file)) {
    file_rel <- rmarkdown:::normalize_path(file)
    if (identical(substr(file_rel, 1, nchar(dir)), dir))
      file_rel <- substr(file_rel, nchar(dir) + 2, nchar(file_rel))
    if (is.null(default_file)) {
      resolved <-  rmarkdown:::resolve_relative(dir, file_rel)
      if (is.null(resolved) || !file.exists(resolved))
        stop("The file '", file, "' does not exist in the directory '",
             dir, "'")
    }
  }
  if (is.null(render_args$envir))
    render_args$envir <- parent.frame()
  target_file <- file %||% file.path(dir, default_file)
  runtime <- if (length(target_file))
    rmarkdown::yaml_front_matter(target_file)$runtime
  if (rmarkdown:::is_shiny_prerendered(runtime)) {
    app <- rmarkdown:::shiny_prerendered_app(target_file, render_args = render_args)
  }
  else {
    onStart <- function() {
      global_r <- rmarkdown:::file.path.ci(dir, "global.R")
      if (file.exists(global_r)) {
        source(global_r, local = FALSE)
      }
      shiny::addResourcePath("rmd_resources", pkg_file("rmd/h/rmarkdown"))
    }
    app <- shiny::shinyApp(ui = rmarkdown:::rmarkdown_shiny_ui(dir, default_file),
                           uiPattern = "^/$|^/index\\.html?$|^(/.*\\.[Rr][Mm][Dd])$",
                           onStart = onStart, server = rmarkdown:::rmarkdown_shiny_server(dir,
                                                                                          default_file, auto_reload, render_args))
    on.exit({
      .globals$evaluated_global_chunks <- character()
    }, add = TRUE)
  }
  launch_browser <- shiny_args$launch.browser %||% (!is.null(file) &&
                                                      interactive())
  if (isTRUE(launch_browser)) {
    launch_browser <- function(url) {
      url <- paste(url, file_rel, sep = "/")
      browser <- getOption("shiny.launch.browser")
      if (is.function(browser)) {
        browser(url)
      }
      else {
        utils::browseURL(url)
      }
    }
  }
  shiny_args <- rmarkdown:::merge_lists(list(appDir = app, launch.browser = launch_browser),
                                        shiny_args)
  ret <- do.call(learnr.dashboard:::.runApp, shiny_args)
  invisible(ret)
}

.runApp <- function (appDir = getwd(), port = getOption("shiny.port"), launch.browser = getOption("shiny.launch.browser", interactive()), host = getOption("shiny.host", "127.0.0.1"),
                     workerId = "", quiet = FALSE, display.mode = c("auto", "normal", "showcase"), test.mode = getOption("shiny.testmode", FALSE))
{
  #' re-implementation of shiny::runApp
  #' this version uses a more restricted range of ports

  # import internal functions/objects
  # source: https://github.com/rstudio/shiny/blob/master/R/globals.R#L2
  .globals <- shiny:::.globals

  on.exit({
    shiny:::handlerManager$clear()
  }, add = TRUE)
  if (.globals$running) {
    stop("Can't call `runApp()` from within `runApp()`. If your ",
         "application code contains `runApp()`, please remove it.")
  }
  .globals$running <- TRUE
  on.exit({
    .globals$running <- FALSE
  }, add = TRUE)
  oldOptionSet <- .globals$options
  on.exit({
    .globals$options <- oldOptionSet
  }, add = TRUE)
  shiny:::shinyOptions(appToken = shiny:::createUniqueId(8))
  ops <- options(warn = max(1, getOption("warn", default = 1)),
                 pool.scheduler = shiny:::scheduleTask)
  on.exit(options(ops), add = TRUE)
  if (is.null(shiny:::getShinyOption("cache"))) {
    shiny:::shinyOptions(cache = shiny:::MemoryCache$new())
  }
  appParts <- shiny:::as.shiny.appobj(appDir)
  appOps <- appParts$options
  findVal <- function(arg, default) {
    if (arg %in% names(appOps))
      appOps[[arg]]
    else default
  }
  if (missing(port))
    port <- findVal("port", port)
  if (missing(launch.browser))
    launch.browser <- findVal("launch.browser", launch.browser)
  if (missing(host))
    host <- findVal("host", host)
  if (missing(quiet))
    quiet <- findVal("quiet", quiet)
  if (missing(display.mode))
    display.mode <- findVal("display.mode", display.mode)
  if (missing(test.mode))
    test.mode <- findVal("test.mode", test.mode)
  if (is.null(host) || is.na(host))
    host <- "0.0.0.0"
  shiny:::workerId(workerId)
  if (shiny:::inShinyServer()) {
    ver <- Sys.getenv("SHINY_SERVER_VERSION")
    if (utils::compareVersion(ver, shiny:::.shinyServerMinVersion) <
        0) {
      warning("Shiny Server v", shiny:::.shinyServerMinVersion,
              " or later is required; please upgrade!")
    }
  }
  shiny:::setShowcaseDefault(0)
  .globals$testMode <- test.mode
  if (test.mode) {
    message("Running application in test mode.")
  }
  if (is.character(appDir)) {
    desc <- shiny:::file.path.ci(if (tolower(tools::file_ext(appDir)) ==
                                     "r")
      dirname(appDir)
      else appDir, "DESCRIPTION")
    if (file.exists(desc)) {
      con <- file(desc, encoding = shiny:::checkEncoding(desc))
      on.exit(close(con), add = TRUE)
      settings <- read.dcf(con)
      if ("DisplayMode" %in% colnames(settings)) {
        mode <- settings[1, "DisplayMode"]
        if (mode == "Showcase") {
          shiny:::setShowcaseDefault(1)
          if ("IncludeWWW" %in% colnames(settings)) {
            .globals$IncludeWWW <- as.logical(settings[1,
                                                       "IncludeWWW"])
            if (is.na(.globals$IncludeWWW)) {
              stop("In your Description file, `IncludeWWW` ",
                   "must be set to `True` (default) or `False`")
            }
          }
          else {
            .globals$IncludeWWW <- TRUE
          }
        }
      }
    }
  }
  if (is.null(.globals$IncludeWWW) || is.na(.globals$IncludeWWW)) {
    .globals$IncludeWWW <- TRUE
  }
  display.mode <- match.arg(display.mode)
  if (display.mode == "normal") {
    shiny:::setShowcaseDefault(0)
  }
  else if (display.mode == "showcase") {
    shiny:::setShowcaseDefault(1)
  }
  require(shiny)
  # default: max_tries = 20
  max_tries = 20
  # default: port_range = c(3000, 8000)
  port_range = c(7000, 8000)
  # default: excluded_ports = c(3659, 4045, 6000, 6665:6669, 6697)
  excluded_ports = c(3659, 4045, 6000, 6665:6669, 6697)
  if (is.null(port)) {
    for (i in 1:max_tries) {
      if (!is.null(.globals$lastPort)) {
        port <- .globals$lastPort
        .globals$lastPort <- NULL
      }
      else {
        # added custom port range and excluded_ports
        while (TRUE) {
          port <- shiny:::p_randomInt(port_range[1], port_range[2])
          if (!port %in% excluded_ports) {
            break
          }
        }
      }
      # startServer and stopServer are apparently functions from httpuv
      # source: https://stackoverflow.com/questions/19613580/shiny-runexample-error-fail-to-create-server
      # added quiet=TRUE, from https://github.com/yihui/servr/commit/2cbd38a953ee4afb61a1e80f8aacd7e31134a95e
      tmp <- try(httpuv::startServer(host, port, list(), quiet = TRUE), silent = TRUE)
      if (!inherits(tmp, "try-error")) {
        httpuv::stopServer(tmp)
        .globals$lastPort <- port
        break
      } else if (i == max_tries){
        # added custom message if no port was found
        stop("Could not find an available port. If this happens again, ask everyone in the Discord to run learnr.dashboard::end_background_tutorial()")
      }
    }
  }
  on.exit({
    .globals$onStopCallbacks$invoke()
    .globals$onStopCallbacks <- shiny:::Callbacks$new()
  }, add = TRUE)
  shiny:::unconsumeAppOptions(appParts$appOptions)
  if (!is.null(appParts$onStop))
    on.exit(appParts$onStop(), add = TRUE)
  if (!is.null(appParts$onStart))
    appParts$onStart()
  server <- shiny:::startApp(appParts, port, host, quiet)
  shiny:::shinyOptions(server = server)
  on.exit({
    httpuv::stopServer(server)
  }, add = TRUE)
  if (!is.character(port)) {
    browseHost <- host
    if (identical(host, "0.0.0.0")) {
      browseHost <- "127.0.0.1"
    }
    else if (identical(host, "::")) {
      browseHost <- "::1"
    }
    if (httpuv::ipFamily(browseHost) == 6L) {
      browseHost <- paste0("[", browseHost, "]")
    }
    appUrl <- paste("http://", browseHost, ":", port, sep = "")
    if (is.function(launch.browser))
      launch.browser(appUrl)
    else if (launch.browser)
      utils::browseURL(appUrl)
  }
  else {
    appUrl <- NULL
  }
  shiny:::callAppHook("onAppStart", appUrl)
  on.exit({
    shiny:::callAppHook("onAppStop", appUrl)
  }, add = TRUE)
  .globals$reterror <- NULL
  .globals$retval <- NULL
  .globals$stopped <- FALSE
  shiny:::..stacktraceoff..(captureStackTraces({
    while (!.globals$stopped) {
      shiny:::..stacktracefloor..(shiny:::serviceApp())
    }
  }))
  if (isTRUE(.globals$reterror)) {
    stop(.globals$retval)
  }
  else if (.globals$retval$visible)
    .globals$retval$value
  else invisible(.globals$retval$value)
}

.open_browser <- function(name, logfile) {
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
          url = strsplit(line, "Listening on ", fixed=TRUE)[[1]][2]
          app_online = TRUE
          break  # break from for loop
        }

        if ( line == "Execution halted" ){
          stop("An error had occured!")
        }
      }
      log_lines_parsed <- len

      if ( app_online ){
        browseURL(url)
        break  # break from while loop
      }
    }
  }
  unlink(logfile)
}
