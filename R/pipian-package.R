#' pipian: Tiny Interface to CaboCha for R
#' @importFrom dplyr %>%
#' @importFrom purrr map_chr imap_dfr
#' @importFrom Rcpp sourceCpp
#' @useDynLib pipian, .registration=TRUE
#' @keywords internal
"_PACKAGE"

#' @noRd
#' @param libpath libpath
.onUnload <- function(libpath) {
  library.dynam.unload("pipian", libpath)
}
