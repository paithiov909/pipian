#' Execute cabocha command
#'
#' Execute cabocha -f3 -n1 command using \code{processx::run},
#' then return path to the result temporary xml files.
#'
#' @param text A character vector to be analyzed by CaboCha.
#' @param rcpath String; path to the `mecabrc` file if any.
#' @return The paths to result xml files is returned.
#' @export
#' @examples
#' \dontrun{
#' ppn_cabocha(
#'   enc2utf8("\u96e8\u306b\u3082\u8ca0\u3051\u305a")
#' )
#' }
ppn_cabocha <- function(text, rcpath = NULL) {
  map_chr(stringi::stri_enc_toutf8(text), function(elem) {
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
