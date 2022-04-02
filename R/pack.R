#' Pack prettified data.frame of tokens
#'
#' @inherit audubon::pack description return details sections seealso
#' @inheritParams audubon::pack
#' @export
pack <- function(tbl, pull = "token", n = 1L, sep = "-", .collapse = " ") {
  pull <- rlang::ensym(pull)
  tbl %>%
    dplyr::filter(.data$token != "EOS") %>%
    audubon::pack(pull, n = n, sep = sep, .collapse = .collapse)
}
