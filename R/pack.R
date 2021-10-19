#' Pack prettified data.frame of tokens
#'
#' Pack prettified data.frame of tokens into a new data.frame of corpus
#' compatible with the Text Interchange Formats.
#'
#' @section Text Interchange Formats (TIF):
#'
#' The Text Interchange Formats are a set of standards
#' that allows R text analysis packages to target defined inputs and outputs
#' for corpora, tokens, and document-term matrices.
#'
#' @section Valid data.frame of tokens:
#'
#' The prettified data.frame of tokens here is a data.frame object
#' compatible with the TIF.
#'
#' A valid TIF data.frame of tokens are expected to have one unique key column (named `doc_id`)
#' of each text and several feature columns of each tokens.
#' Feature columns must include at least `token` itself.
#'
#' @seealso \url{https://github.com/ropensci/tif}
#'
#' @param df Prettified data.frame of tokens.
#' @param n Integer passed to \code{quanteda::char_ngrams}.
#' @param skip Integer passed to \code{quanteda::char_ngrams}.
#' @param pull Column to be packed into text or ngrams body. Default value is `token`.
#' @param sep Character scalar internally used as the concatenator of ngrams
#' inside \code{quanteda::char_ngrams}.
#' @param .collapse Character scalar passed to \code{stringi::stri_c()}.
#' @return data.frame
#'
#' @export
pack <- function(df, n = 1L, skip = 0L, pull = "token", sep = "_", .collapse = " ") {
  res <- df %>%
    dplyr::filter(token != "EOS") %>%
    dplyr::group_by(!!sym("doc_id")) %>%
    dplyr::group_map(
      ~ dplyr::pull(.x, {{ pull }}) %>%
        quanteda::char_ngrams(n = n, skip = skip, concatenator = sep) %>%
        stringi::stri_c(collapse = .collapse)
    ) %>%
    imap_dfr(~ data.frame(doc_id = .y, text = .x))
  return(res)
}
