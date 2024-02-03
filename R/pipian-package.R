#' @importFrom dplyr %>%
#' @importFrom rlang expr enquo enquos sym syms .data := as_name as_label
#' @importFrom Rcpp sourceCpp
#' @importFrom utils globalVariables
#' @useDynLib pipian, .registration=TRUE
#' @keywords internal
"_PACKAGE"

utils::globalVariables("where")

#' @noRd
#' @param libpath libpath
.onUnload <- function(libpath) {
  library.dynam.unload("pipian", libpath)
}
