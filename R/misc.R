#' Check if cabocha command is available
#'
#' @param version version of CaboCha available.
#' @return logical
#'
#' @export
is_cabocha_available <- function(version = "0.69") {
  intern <- try(system("cabocha --version", intern = TRUE))
  return(intern == paste("cabocha of", version, collapse = " "))
}
