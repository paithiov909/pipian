#' Pack prettified data.frame of tokens
#'
#' @inherit audubon::pack description return details sections seealso
#' @inheritParams audubon::pack
#' @export
pack <- function(df, n = 1L, pull = "token", sep = "-", .collapse = " ") {
  df %>%
    dplyr::filter(.data$token != "EOS") %>%
    audubon::pack(n, pull = pull, sep = sep, .collapse = .collapse)
}
