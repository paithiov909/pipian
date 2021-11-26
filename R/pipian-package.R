#' pipian: Tiny Interface to CaboCha for R
#' @importFrom dplyr %>%
#' @importFrom rlang expr enquo enquos sym syms .data := as_name as_label
#' @importFrom Rcpp sourceCpp
#' @useDynLib pipian, .registration=TRUE
#' @keywords internal
"_PACKAGE"

#' @noRd
#' @param libpath libpath
.onUnload <- function(libpath) {
  library.dynam.unload("pipian", libpath)
}
