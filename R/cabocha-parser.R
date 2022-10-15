#' Parse XML output of CaboCha
#'
#' @param path String; output from \code{pipian::ppn_cabocha}.
#' @param into Character vector; feature names of output.
#' @param col_select Character or integer vector; features that will be kept
#' in the result.
#' @returns A data.frame.
#' @export
#' @examples
#' head(ppn_parse_xml(system.file("sample.xml", package = "pipian")))
ppn_parse_xml <- function(path,
                          into = c(
                            "POS1",
                            "POS2",
                            "POS3",
                            "POS4",
                            "X5StageUse1",
                            "X5StageUse2",
                            "Original",
                            "Yomi1",
                            "Yomi2"
                          ),
                          col_select = seq_along(into)) {
  if (is.numeric(col_select) && max(col_select) <= length(into)) {
    col_select <- which(seq_along(into) %in% col_select, arr.ind = TRUE)
  } else {
    col_select <- which(into %in% col_select, arr.ind = TRUE)
  }
  if (rlang::is_empty(col_select)) {
    rlang::abort("Invalid columns have been selected.")
  }
  tokens <-
    purrr::imap_dfr(path, function(.x, .y) {
      df <- parse_xml(.x)
      if (rlang::is_empty(df)) {
        data.frame()
      } else {
        suppressWarnings({
          ## ignore warnings when there are missing columns.
          features <-
            c(
              stringi::stri_c(into, collapse = ","),
              dplyr::pull(df, "token_feature")
            ) %>%
            stringi::stri_c(collapse = "\n") %>%
            I() %>%
            readr::read_csv(
              col_types = stringi::stri_c(rep("c", length(into)), collapse = ""),
              col_select = col_select,
              na = c("*"),
              progress = FALSE,
              show_col_types = FALSE
            )
        })
        df %>%
          dplyr::mutate(
            doc_id = .y,
            sentence_id = as.integer(.data$sentence_id) + 1L,
            chunk_id = as.integer(.data$chunk_id) + 1L,
            token_id = as.integer(.data$token_id),
            token = reset_encoding(.data$token),
            chunk_link = as.integer(.data$chunk_link) + 1L,
            chunk_score = as.numeric(.data$chunk_score),
            chunk_head = as.integer(.data$chunk_head) + 1L,
            chunk_func = as.integer(.data$chunk_func),
            token_entity = dplyr::na_if(reset_encoding(.data$token_entity), "O")
          ) %>%
          dplyr::select(!"token_feature") %>%
          dplyr::bind_cols(features) %>%
          dplyr::rename(entity = .data$token_entity) %>%
          dplyr::relocate("doc_id", dplyr::everything())
      }
    })
  return(tokens)
}

#' Cast dependency structure as an igraph
#'
#' @param df Output of \code{pipian::ppn_parse_xml}.
#' @returns An 'igraph' object is returned.
#' @export
#' @examples
#' xml <- ppn_parse_xml(system.file("sample.xml", package = "pipian"))
#' ppn_make_graph(xml)
ppn_make_graph <- function(df) {
  df <- df %>%
    dplyr::group_by(.data$doc_id, .data$sentence_id, .data$chunk_id) %>%
    dplyr::transmute(
      name = stringi::stri_join(.data$doc_id, .data$sentence_id, .data$chunk_id),
      from = stringi::stri_join(.data$doc_id, .data$sentence_id, .data$chunk_id),
      to = stringi::stri_join(.data$doc_id, .data$sentence_id, .data$chunk_link),
      tokens = stringi::stri_join(.data$token, collapse = " "),
      pos = stringi::stri_join(.data$POS1, collapse = ","),
      score = .data$chunk_score
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(
      "name",
      "from",
      "to",
      "tokens",
      "pos",
      "score"
    ) %>%
    dplyr::distinct()

  g <- igraph::graph_from_data_frame(
    dplyr::select(df, "from", "to", "score"),
    dplyr::select(df, "name", "tokens", "pos"),
    directed = TRUE
  )
  return(g)
}
