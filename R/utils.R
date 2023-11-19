#' Check if CaboCha command is available
#' @returns Logical.
#' @keywords internal
is_cabocha_available <- function() {
  wh <- Sys.which("cabocha")
  return(!identical(unname(wh), ""))
}

#' Pipe operator
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
NULL
