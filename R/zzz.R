#' On attach
#' @noRd
#' @param libname libname
#' @param pkgname pkgname
.onAttach <- function(libname, pkgname) {
  # Sys.setenv("PKG_LIBS" = "-lmecab -lcabocha")
}
#' On unload
#' @noRd
#' @param libname libpath
.onUnload <- function(libpath) {
  # library.dynam.unload("pipian", libpath)
}
