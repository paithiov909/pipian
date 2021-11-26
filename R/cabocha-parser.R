#' Parse XML output of CaboCha
#'
#' @param path String; output from \code{pipian::ppn_cabocha}.
#' @param into Character vector; the feature names of output.
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
                          )) {
  tokens <-
    imap_dfr(path, function(.x, .y) {
      df <- parse_xml(.x)
      if (rlang::is_empty(df)) {
        data.frame()
      } else {
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
            token_feature = reset_encoding(.data$token_feature),
            token_entity = dplyr::na_if(reset_encoding(.data$token_entity), "O")
          ) %>%
          tidyr::separate(
            .data$token_feature,
            into = into,
            sep = ",",
            fill = "right"
          ) %>%
          dplyr::mutate_if(is.character, ~ dplyr::na_if(., "*")) %>%
          dplyr::rename(entity = .data$token_entity) %>%
          dplyr::relocate(.data$doc_id, dplyr::everything())
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
      tokens = stringi::stri_c(.data$token, collapse = " "),
      pos = stringi::stri_c(.data$POS1, collapse = ","),
      score = .data$chunk_score
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(
      .data$name,
      .data$from,
      .data$to,
      .data$tokens,
      .data$pos,
      .data$score
    ) %>%
    dplyr::distinct()

  g <- igraph::graph_from_data_frame(
    dplyr::select(df, .data$from, .data$to, .data$score),
    dplyr::select(df, .data$name, .data$tokens, .data$pos),
    directed = TRUE
  )
  return(g)
}
