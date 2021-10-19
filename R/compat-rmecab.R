#' Gibasa functions family
#'
#' These functions are compact RMeCab alternatives
#' based on \href{https://quanteda.io/}{quanteda}.
#'
#' @seealso gbs_freq, gbs_c, gbs_as_tokens, gbs_dfm, gbs_collocate
#' @rdname gibasa
#' @name gibasa
#' @keywords internal
NULL

#' An alternative of RMeCabFreq
#'
#' @param df A prettified data.frame of tokenized sentences.
#' @param ... Other arguments are passed to \code{dplyr::tally()}.
#' @param .name_repair Logical:
#' If true, then rename the column names as RMecabFreq-compatible style.
#' @returns A data.frame.
#' @family gibasa
#' @export
#' @examples
#' xml <- ppn_parse_xml(system.file("sample.xml", package = "pipian"))
#' head(gbs_freq(xml))
gbs_freq <- function(df, ..., .name_repair = TRUE) {
  df <- df %>%
    dplyr::filter(.data$token != "EOS") %>%
    dplyr::group_by(.data$token, .data$POS1, .data$POS2) %>%
    dplyr::tally(...) %>%
    dplyr::ungroup()
  if (.name_repair) {
    df <-
      dplyr::rename(
        df,
        Term = .data$token,
        Info1 = .data$POS1,
        Info2 = .data$POS2,
        Freq = .data$n
      )
  }
  return(df)
}

#' An alternative of RMeCabC
#'
#' @param df A prettified data.frame of tokenized sentences.
#' @param pull A column name of `df`.
#' @param names A column name of `df`.
#' @return A list of named vectors.
#' @family gibasa
#' @export
#' @examples
#' xml <- ppn_parse_xml(system.file("sample.xml", package = "pipian"))
#' head(gbs_c(xml)[[1]])
gbs_c <- function(df, pull = "token", names = "POS1") {
  pull <- rlang::arg_match(pull)
  re <- df %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::group_map(function(.x, .y) {
      purrr::set_names(dplyr::pull(.x, {{ pull }}), dplyr::pull(.x, {{ names }}))
    })
  return(re)
}

#' Pack prettified output as quanteda tokens
#'
#' @inheritParams pack
#' @param what Character scalar; which tokenizer to use in \code{quanteda::tokens()}.
#' @param ... Other arguments are passed to \code{quanteda::tokens()}.
#' @return A quanteda 'token' class object.
#' @family gibasa
#' @export
#' @examples
#' xml <- ppn_parse_xml(system.file("sample.xml", package = "pipian"))
#' gbs_as_tokens(xml)
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
#' @returns A quanteda 'dfm' object.
#' @family gibasa
#' @export
#' @examples
#' xml <- ppn_parse_xml(system.file("sample.xml", package = "pipian"))
#' gbs_dfm(xml)
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
#' @return A quanteda 'fcm' object.
#' @family gibasa
#' @export
#' @examples
#' xml <- ppn_parse_xml(system.file("sample.xml", package = "pipian"))
#' gbs_collocate(xml)
gbs_collocate <- function(df, pull = "token", n = 1L, sep = "-", what = "fastestword", ...) {
  res <-
    gbs_dfm(df, pull = pull, n = n, sep = sep, what = what, ...) %>%
    quanteda::fcm()
  return(res)
}
