#' Format character vector
#' @param vec Character vector.
#' @param enc Encoding of `vec`.
#' @returns Formatted character vector is returned.
#' @keywords internal
reset_encoding <- function(vec, enc = "UTF-8") {
  sapply(vec, function(elem) {
    Encoding(elem) <- enc
    return(elem)
  }, USE.NAMES = FALSE)
}

#' Check if cabocha command is available
#' @returns Logical.
#' @keywords internal
is_cabocha_available <- function() {
  intern <- tryCatch(
    {
      system("cabocha --version", intern = TRUE)
    },
    error = function(e) {
      NULL
    }
  )
  return(!rlang::is_empty(intern))
}

#' Pipe operator
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
NULL
