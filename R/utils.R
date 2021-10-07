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


# checking os functions. port from r-tensorflow


#' @keywords internal
#' @noRd
is_windows <- function() {
    identical(.Platform$OS.type, "windows")
}

#' @keywords internal
#' @noRd
is_unix <- function() {
    identical(.Platform$OS.type, "unix")
}

#' @keywords internal
#' @noRd
is_osx <- function() {
    Sys.info()["sysname"] == "Darwin"
}

#' @keywords internal
#' @noRd
is_linux <- function() {
    identical(tolower(Sys.info()[["sysname"]]), "linux")
}

#' @keywords internal
#' @noRd
is_ubuntu <- function() {
    if (is_unix() && file.exists("/etc/lsb-release")) {
        lsbrelease <- readLines("/etc/lsb-release")
        any(grepl("Ubuntu", lsbrelease))
    } else {
        FALSE
    }
}
