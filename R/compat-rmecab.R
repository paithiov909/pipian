#' Gibasa functions family
#' @description
#' These functions are compact RMeCab alternatives
#' based on \href{https://quanteda.io/}{quanteda}.
#' @rdname gibasa
#' @name gibasa
#' @seealso gbs_freq, gbs_c, gbs_as_tokens, gbs_dfm, gbs_collocate
#' @keywords internal
#' @importFrom dplyr %>%
#' @importFrom rlang expr enquo enquos sym syms .data := as_name as_label
## This module imports:
##  `%>%` from dplyr
##  `expr enquo enquos sym syms .data := as_name as_label` from rlang
## and depends on dplyr, purrr, rlang and quanteda by itself.
NULL


#' An alternative of RMeCabFreq
#'
#' @param df Prettified data.frame of tokenized sentences.
#' @param ... Other arguments are passed to \code{dplyr::tally()}.
#' @param .name_repair Logical.
#' If true, then rename column names to RMecabFreq compatible style.
#' @return tibble
#'
#' @family gibasa
#' @export
gbs_freq <- function(df, ..., .name_repair = TRUE) {
  df <- df %>%
    dplyr::filter(token != "EOS") %>%
    dplyr::group_by(token, POS1, POS2) %>%
    dplyr::tally(...) %>%
    dplyr::ungroup()
  if (.name_repair) {
    df <-
      dplyr::rename(
        df,
        Term = token,
        Info1 = POS1,
        Info2 = POS2,
        Freq = n
      )
  }
  return(df)
}

#' An alternative of RMeCabC
#'
#' @param df Prettified data.frame of tokenized sentences.
#' @param pull A column name of df.
#' @param names A column name of df.
#' @return list of named vectors
#'
#' @family gibasa
#' @export
gbs_c <- function(df, pull = "token", names = "POS1") {
  pull <- rlang::arg_match(pull)
  re <- df %>%
    dplyr::group_by(!!sym("doc_id")) %>%
    dplyr::group_map(function(.x, .y) {
      purrr::set_names(dplyr::pull(.x, {{ pull }}), dplyr::pull(.x, {{ names }}))
    })
  return(re)
}

#' Pack prettified output as quanteda tokens
#'
#' @inheritParams pack
#' @param what Character scalar. Which tokenizer to use in \code{quanteda::tokens()}.
#' @param ... Other arguments are passed to \code{quanteda::tokens()}.
#' @return quanteda token class object
#'
#' @family gibasa
#' @export
gbs_as_tokens <- function(df, pull = "token", n = 1L, sep = "-", what = "fastestword", ...) {
  df <-
    pack(df, pull = pull, n = n, sep = sep) %>%
    quanteda::corpus() %>%
    quanteda::tokens(what = what, ...)
  return(df)
}

#' An alternative of docDF family
#'
#' Create a sparse document-feature matrix.
#' This function is a shorthand of
#' \code{pipian::gbs_as_tokens()} and then \code{quatenda::dfm()}.
#'
#' @inheritParams gbs_as_tokens
#' @return quanteda dfm object
#'
#' @family gibasa
#' @export
gbs_dfm <- function(df, pull = "token", n = 1L, sep = "-", what = "fastestword", ...) {
  res <-
    gbs_as_tokens(df, pull = pull, n = n, sep = sep, what = what, ...) %>%
    quanteda::dfm()
  return(res)
}

#' A mimic of collocate
#'
#' Create a sparse feature co-occurrence matrix.
#' This function is a shorthand of
#' \code{pipian::gbs_dfm()} and then \code{quanteda::fcm()}.
#'
#' @inheritParams gbs_as_tokens
#' @return quanteda fcm object
#'
#' @family gibasa
#' @export
gbs_collocate <- function(df, pull = "token", n = 1L, sep = "-", what = "fastestword", ...) {
  res <-
    gbs_dfm(df, pull = pull, n = n, sep = sep, what = what, ...) %>%
    quanteda::fcm()
  return(res)
}
