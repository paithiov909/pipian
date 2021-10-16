#' Execute cabocha command
#'
#' Execute cabocha -f3 -n1 command using \code{processx::run},
#' then return path to the result files.
#'
#' @param text Character vector to be analyzed by CaboCha.
#' @param rcpath String scalar that path to the `mecabrc` file if any.
#' @return Character vector that path to result xml files.
#'
#' @export
ppn_cabocha <- function(text, rcpath = NULL) {
  map_chr(text, function(elem) {
    data <- tempfile(fileext = ".xml")
    tmp_file_txt <- tempfile(fileext = ".txt")

    readr::write_lines(elem, tmp_file_txt)

    if (!is.null(rcpath)) {
      processx::run(
        "cabocha",
        args = c(
          "-f3",
          "-n1",
          file.path(tmp_file_txt),
          "-o",
          data,
          "-b",
          rcpath
        )
      )
    } else {
      processx::run(
        "cabocha",
        args = c(
          "-f3",
          "-n1",
          file.path(tmp_file_txt),
          "-o",
          data
        )
      )
    }

    out <- readr::read_lines(data)
    tmp <- tempfile(fileext = ".xml")

    readr::write_lines("<sentences>", tmp, append = TRUE)
    readr::write_lines(out, tmp, append = TRUE)
    readr::write_lines("</sentences>", tmp, append = TRUE)

    return(file.path(tmp))
  })
}
