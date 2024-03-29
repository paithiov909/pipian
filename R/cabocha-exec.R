#' Execute cabocha command
#'
#' Execute `cabocha -f3 -n1` command using \code{system2},
#' then return the paths to the temporary XML files.
#'
#' @param text A character vector to be parsed with CaboCha.
#' @param rcpath String; path to the `mecabrc` file if any.
#' @returns Paths to the CaboCha XML output are returned.
#' @export
#' @examples
#' \dontrun{
#' ppn_cabocha(enc2utf8("\u96e8\u306b\u3082\u8ca0\u3051\u305a"))
#' }
ppn_cabocha <- function(text, rcpath = NULL) {
  tmp_file_txt <- tempfile(fileext = ".txt")

  purrr::map_chr(stringi::stri_enc_toutf8(text), function(elem) {
    data <- tempfile(fileext = ".xml")

    readr::write_lines(elem, tmp_file_txt, append = FALSE)

    if (!is.null(rcpath)) {
      system2(
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
      system2(
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
