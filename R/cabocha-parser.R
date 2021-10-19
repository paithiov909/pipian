#' Cast XML as data.table
#' @param tokens Output from \code{pipian::ppn_parse_xml}.
#' @returns A data.table casted with \code{rsyntax::as_tokenindex} is returned.
#' @examples
#' xml <- ppn_parse_xml(system.file("sample.xml", package = "pipian"))
#' head(ppn_as_tokenindex(xml))
#' @export
ppn_as_tokenindex <- function(tokens) {
  res <- tokens %>%
    dplyr::mutate(
      doc_id = .data$doc_id,
      sentence_id = .data$sentence_id,
      token_id = stringi::stri_join(.data$doc_id, .data$sentence_id, .data$chunk_id, .data$token_id),
      pos = .data$POS1,
      parent = stringi::stri_join(.data$doc_id, .data$sentence_id, .data$chunk_id, .data$chunk_func)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(-c("chunk_id", "chunk_link", "chunk_head", "chunk_func")) %>%
    dplyr::mutate(
      token_id = as.integer(.data$token_id),
      parent = as.integer(.data$parent)
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
          dplyr::mutate(dplyr::across(where(is.character), ~ dplyr::na_if(., "*"))) %>%
          dplyr::rename(entity = .data$token_entity) %>%
          dplyr::relocate(.data$doc_id, dplyr::everything())
      }
    })
  return(tokens)
}

#' Plot dependency structure using igraph
#'
#' @param df Output of \code{pipian::ppn_parse_xml}.
#' @returns The graph object is returned invisibly.
#' @export
#' @examples
#' \dontrun{
#'   xml <- ppn_parse_xml(system.file("sample.xml", package = "pipian"))
#'   ppn_plot_igraph(xml)
#' }
ppn_plot_igraph <- function(df) {
  df <- df %>%
    dplyr::group_by(.data$doc_id, .data$sentence_id, .data$chunk_id) %>%
    dplyr::transmute(
      name = stringi::stri_join(.data$doc_id, .data$sentence_id, .data$chunk_id),
      from = stringi::stri_join(.data$doc_id, .data$sentence_id, .data$chunk_id),
      to = stringi::stri_join(.data$doc_id, .data$sentence_id, .data$chunk_link),
      tokens = stringi::stri_c(.data$token, collapse = " "),
      score = .data$chunk_score
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(.data$name, .data$from, .data$to, .data$tokens, .data$score) %>%
    dplyr::distinct()

  g <- igraph::graph_from_data_frame(
    dplyr::select(df, .data$from, .data$to, .data$score),
    dplyr::select(df, .data$name, .data$tokens),
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
  return(invisible(g))
}
