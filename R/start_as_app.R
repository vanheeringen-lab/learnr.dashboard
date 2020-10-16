#' @export
start_app <- function(lesson="/home/siebrenf/git/edu/learnr.proto/inst/tutorials/test/test.Rmd") {
  #' start lesson as shiny markdown

  # Doesn't always start if the html exists.
  # (this may causes issues with multiple users)
  rmarkdown::shiny_prerendered_clean(lesson)

  # start shiny app from code here
  rmarkdown::run(
    lesson,
    shiny_args = list(launch.browser = TRUE)  # opens the lesson in a new browser tab
  )

}

#' @export
dev.a <- function() {
  #' dev only
  #' update lesson and run as shiny markdown

  libpath = "/home/siebrenf/miniconda3/envs/learnr/lib/R/library"
  lesson <- "/home/siebrenf/git/edu/learnr.proto/inst/tutorials/test/test.Rmd"

  set_lib_paths(libpath)

  # for some reason it doesn't always start if the html exists.
  # this may causes issues with multiple users.
  rmarkdown::shiny_prerendered_clean(lesson)

  # start shiny app from code here
  rmarkdown::run(
    lesson,
    shiny_args = list(launch.browser = TRUE)  # opens the lesson in a new browser tab
  )

}

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
