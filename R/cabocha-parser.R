#' Cast xml as data.table
#' @param tokens Output from \code{pipian::ppn_parse_xml}.
#' @return data.table retured from \code{rsyntax::as_tokenindex}.
#' @export
ppn_as_tokenindex <- function(tokens) {
  res <- tokens %>%
    dplyr::mutate(
      doc_id = doc_id,
      sentence_id = sentence_id,
      token_id = stringi::stri_join(doc_id, sentence_id, chunk_id, token_id),
      pos = POS1,
      parent = stringi::stri_join(doc_id, sentence_id, chunk_id, chunk_func)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(-c("chunk_id", "chunk_link", "chunk_head", "chunk_func")) %>%
    dplyr::mutate(
      token_id = as.integer(token_id),
      parent = as.integer(parent)
    )

  return(
    rsyntax::as_tokenindex(
      res,
      doc_id = "doc_id",
      sentence = "sentence_id",
      token_id = "token_id",
      parent = "parent",
      relation = "pos"
    )
  )
}

#' Parse xml output of CaboCha
#' @param path Character vector came from \code{ppn_cabocha}.
#' @param into Character vector. Feature names of output.
#' @return data.frame
#' @export
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
      parse_xml(.x) %>%
        dplyr::mutate(
          doc_id = .y, # 1-origin
          sentence_id = as.integer(sentence_id) + 1L,
          chunk_id = as.integer(chunk_id) + 1L,
          token_id = as.integer(token_id),
          token = reset_encoding(token),
          chunk_link = as.integer(chunk_link) + 1L,
          chunk_score = as.numeric(chunk_score),
          chunk_head = as.integer(chunk_head) + 1L,
          chunk_func = as.integer(chunk_func),
          token_feature = reset_encoding(token_feature),
          token_entity = dplyr::na_if(reset_encoding(token_entity), "O")
        ) %>%
        tidyr::separate(
          token_feature,
          into = into,
          sep = ",",
          fill = "right"
        ) %>%
        dplyr::mutate(across(where(is.character), ~ dplyr::na_if(., "*"))) %>%
        dplyr::rename(entity = token_entity) %>%
        dplyr::relocate(doc_id, everything())
    })
  return(tokens)
}

#' Plot dependency strutcure using igraph
#' @param df Output of \code{ppn_parse_xml}.
#' @param doc_id Document id to be kept in igraph.
#' @param sentence_id Sentence id to be kept in igraph.
#' @export
ppn_plot_igraph <- function(df, doc_id = 1L, sentence_id = 1L) {
  df <- df %>%
    dplyr::filter(doc_id == doc_id, sentence_id == sentence_id) %>%
    dplyr::group_by(doc_id, sentence_id, chunk_id) %>%
    dplyr::transmute(
      name = stringi::stri_join(doc_id, sentence_id, chunk_id),
      from = stringi::stri_join(doc_id, sentence_id, chunk_id),
      to = stringi::stri_join(doc_id, sentence_id, chunk_link),
      tokens = stringi::stri_c(token, collapse = " "),
      score = chunk_score
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(name, from, to, tokens, score) %>%
    dplyr::distinct()

  g <- igraph::graph_from_data_frame(
    dplyr::select(df, from, to, score),
    dplyr::select(df, name, tokens),
    directed = TRUE
  )

  pagerank <- igraph::page.rank(g, directed = TRUE)

  plot(
    g,
    vertex.size = pagerank$vector * 50,
    vertex.color = "steelblue",
    vertex.label = igraph::V(g)$tokens,
    vertex.label.cex = 0.8,
    vertex.label.color = "black",
    edge.width = 0.4,
    edge.arrow.size = 0.4,
    edge.color = "gray80",
    layout = igraph::layout_as_tree(g, mode = "in", flip.y = FALSE)
  )
}
