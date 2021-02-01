#' @keywords internal
.start_app <- function(name = "test", package = "learnr.proto") {
  #' start tutorial from package as shiny markdown
  #' example: learnr.dashboard:::.start_app("fg1")

  tutorial_path <- system.file("tutorials", name, package = package)

  # Doesn't always start if the html exists.
  # (this may causes issues with multiple users)
  rmd_file = file.path(tutorial_path, list.files(tutorial_path, pattern = "*.Rmd")[1])
  rmarkdown::shiny_prerendered_clean(rmd_file)

  # start shiny app from code here
  rmarkdown::run(
    file = NULL,
    dir = tutorial_path,
    # opens the tutorial in a new browser tab
    # shiny_args = list(launch.browser = TRUE)
    shiny_args = list(
      launch.browser = (interactive() || identical(Sys.getenv("LEARNR_INTERACTIVE", "0"), "1"))
    )
  )
}

#' @keywords internal
.start_dev_app <- function(name="test", tutorial_dir="/home/siebrenf/git/edu/learnr.proto/inst/tutorials") {
  #' start dev tutorial as shiny markdown
  #' works without reinstalling the package first
  #' example: learnr.dashboard:::.start_dev_app("fg1")

  tutorial_path = file.path(tutorial_dir, name)

  # Doesn't always start if the html exists.
  # (this may causes issues with multiple users)
  rmarkdown::shiny_prerendered_clean(tutorial_path)

  # start shiny app from code here
  rmarkdown::run(
    file = NULL,
    dir = tutorial_path,
    # shiny_args = list(launch.browser = TRUE)
    shiny_args = list(
      launch.browser = (interactive() || identical(Sys.getenv("LEARNR_INTERACTIVE", "0"), "1"))
    )
  )

}

# dev.a <- function() {
#   #' dev only
#   #' update lesson and run as shiny markdown
#
#   libpath = "/home/siebrenf/miniconda3/envs/learnr/lib/R/library"
#   lesson <- "/home/siebrenf/git/edu/learnr.proto/inst/tutorials/test/test.Rmd"
#
#   learnr.dashboard::set_lib_paths(libpath)
#
#   # for some reason it doesn't always start if the html exists.
#   # this may causes issues with multiple users.
#   rmarkdown::shiny_prerendered_clean(lesson)
#
#   # start shiny app from code here
#   rmarkdown::run(
#     lesson,
#     shiny_args = list(launch.browser = TRUE)  # opens the lesson in a new browser tab
#   )
#
# }

# dev.a2 <- function() {
#   # copy lesson to some dir, then run there
#
#   libpath = "/home/siebrenf/miniconda3/envs/learnr/lib/R/library"
#   set_lib_paths(libpath)
#
#   # pkg = "/home/siebrenf/git/edu/learnr.proto"
#   source_lesson_path <- "/home/siebrenf/git/edu/learnr.proto/inst/tutorials/test/test.Rmd"
#   course_dir <- '/bank/experiments/2020-10/education'
#
#   # keep track of all user in a separate directory
#   username <- basename('~')
#   lesson_file <- basename(source_lesson_path)
#   lesson_name <- strsplit(lesson_file, "\\.")[[1]][1]
#   lesson_dir <- file.path(course_dir, "users", username, lesson_name)
#   dir.create(lesson_dir, showWarnings=FALSE, recursive = TRUE, mode = "0777")
#
#   # copy the lesson here, so we can pre-render and clean the lesson for each user
#   destination_lesson_path <- file.path(lesson_dir, lesson_file)  # '/bank/experiments/2020-10/education/users/siebrenf/learnr_proto/learnr_proto.Rmd'
#   file.copy(
#     source_lesson_path,
#     destination_lesson_path,
#     overwrite = TRUE
#   )
#
#   # for some reason it doesn't start if the html already exists... this might be an issue with markdown
#   # this may causes issues with multiple users. must redirect this to a user specific folder if it cant be circumvented
#   rmarkdown::shiny_prerendered_clean(destination_lesson_path)
#
#   # start shiny app from code here
#   rmarkdown::run(
#     destination_lesson_path,
#     shiny_args = list(launch.browser = TRUE)  # opens the lesson in a new browser tab
#   )
#
# }
