# On attach
.onAttach <- function(libname, pkgname) {
  # Sys.setenv("PKG_LIBS" = "-lmecab -lcabocha")
}
# On unload
.onUnload <- function(libpath) {
  # library.dynam.unload("pipian", libpath)
}
