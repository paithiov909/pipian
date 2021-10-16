#' Format character vector
#' @param vec Character vector.
#' @param enc Encoding of vec.
#' @keywords internal
reset_encoding <- function(vec, enc = "UTF-8") {
  sapply(vec, function(elem) {
    Encoding(elem) <- enc
    return(elem)
  }, USE.NAMES = FALSE)
}

#' Check if cabocha command is available
#' @param version Version number of CaboCha.
#' @return Logical.
#' @keywords internal
is_cabocha_available <- function(version = "0.69") {
  intern <- try(system("cabocha --version", intern = TRUE))
  return(intern == paste("cabocha of", version, collapse = " "))
}

#' Pipe operator
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
NULL
