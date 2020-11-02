#' Call cabocha -f3 command
#'
#' Calls cabocha -f3 command via \code{system()}, then returns results as a flat XML.
#' It requires that CaboCha has already been installed and available.
#'
#' @param texts characters that you want to pass to CaboCha.
#' @param rcpath path to MECABRC if any.
#' @param as.tibble boolean. If false, then return flatXML dataframe.
#' @param force.utf8 boolean. If true, it reads cabocha output xml with UTF-8.
#' @param ... other arguments are passed to \code{tibble::as_tibble()}.
#'
#' @return flat XML made by \code{flatxml::fxml_importXMLFlat(CaboChaOutputXML)}
#'
#' @importFrom readr write_lines
#' @importFrom flatxml fxml_importXMLFlat
#' @importFrom tibble as_tibble
#' @importFrom dplyr %>%
#' @export
cabochaFlatXML <- function(texts,
                           rcpath = NULL,
                           as.tibble = FALSE,
                           force.utf8 = FALSE,
                           ...) {
  ENC <- switch(.Platform$pkgType, "win.binary" = "CP932", "UTF-8")
  if (force.utf8) ENC <- "UTF-8"

  tmp_file_txt <- tempfile(fileext = ".txt")
  writeLines(texts, con = tmp_file_txt, useBytes = TRUE)

  if (!is.null(rcpath)) {
    system(paste(
      "cabocha -f3 -n 1",
      file.path(tmp_file_txt),
      "-o",
      file.path(tempdir(), "data.xml"),
      "-b",
      rcpath
    ))
  } else {
    system(paste(
      "cabocha -f3 -n 1",
      file.path(tmp_file_txt),
      "-o",
      file.path(tempdir(), "data.xml")
    ))
  }

  out <- readLines(file.path(tempdir(), "data.xml"), encoding = ENC)
  tmp <- tempfile(fileext = ".xml")

  readr::write_lines("<sentences>", tmp)
  readr::write_lines(iconv(out, from = ENC, to = "UTF-8"), tmp, append = TRUE)
  readr::write_lines("</sentences>", tmp, append = TRUE)

  flatdf <- flatxml::fxml_importXMLFlat(file.path(tmp))

  unlink(tmp_file_txt)
  unlink(tmp)

  if (as.tibble) {
    flatdf %>%
      tibble::as_tibble(...) %>%
      return()
  } else {
    flatdf %>%
      return()
  }
}
