#' Utility for parsing CaboCha output
#'
#' Pluck a value from feature attribute of CaboCha output tok.
#'
#' @param str strings representing feature attribute of CaboCha output tok.
#' @param idx index to pluck.
#'
#' @importFrom stringr str_split
#' @importFrom stringr str_c
#' @importFrom dplyr %>%
#' @export
pluckAttrs <- function(str, idx) {
    split <- stringr::str_split(str, ",", simplify = TRUE)
    split %>%
        lapply(function(split){return(split[idx])}) %>%
        unlist() %>%
        stringr::str_c(collapse="")
}
