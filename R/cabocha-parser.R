#' @noRd
#' @keywords internal
R6_CabochaR <- R6::R6Class(
  "CabochaR",
  public = list(
    attributes = NULL,
    morphs = NULL,
    initialize = function(attributes, morphs) {
      self$attributes <- attributes
      self$morphs <- morphs
    },
    as_tibble = function(attr = self$attributes, dfs = self$morphs) {
      purrr::imap_dfr(dfs, function(df, idx) {
        df %>%
          dplyr::mutate(sentence_idx = idx) %>%
          dplyr::right_join(attr, by = "chunk_idx") %>%
          dplyr::select(
            "sentence_idx",
            "chunk_idx",
            "D1",
            "D2",
            "rel",
            "score",
            "head",
            "func",
            "tok_idx",
            "ne_value",
            "Surface",
            "POS1",
            "POS2",
            "POS3",
            "POS4",
            "X5StageUse1",
            "X5StageUse2",
            "Original",
            "Yomi1",
            "Yomi2"
          )
      })
    }
  )
)


#' Utility for parsing CaboCha output
#'
#' converts flat XML into CabochaR compatible output.
#'
#' @param fxml flat XML that comes from \code{cabochaFlatXML(as.tibble = FALSE)}
#'
#' @return R6 class object having fields and methods below.
#' \itemize{
#'   \item attributes: tibble. Each rows consist of the element id and attributes of chunk.
#'   \item morphs: list of tibbles. Each rows represent morphemes of which the chunk is made.
#'   \item as_tibble(): return a tibble compatible with CabochaR output.
#' }
#'
#' @seealso \url{https://minowalab.org/cabochar/}
#'
#' @import R6
#' @import dplyr
#' @importFrom purrr imap
#' @importFrom purrr map_dfr
#' @importFrom purrr imap_dfr
#' @importFrom purrr keep
#' @importFrom tidyr drop_na
#' @importFrom flatxml fxml_getChildren
#' @importFrom flatxml fxml_getAttribute
#' @importFrom flatxml fxml_getAttributesAll
#' @importFrom stringr str_split
#' @importFrom tibble tibble
#' @importFrom tidyr drop_na
#' @export
CabochaR <- function(fxml) {
  sentence_ids <- fxml %>%
    as.data.frame(stringsAsFactors = FALSE) %>%
    dplyr::filter(elem. == "sentence") %>%
    dplyr::distinct(elemid.)

  chunk_ids <- fxml %>%
    as.data.frame(stringsAsFactors = FALSE) %>%
    dplyr::filter(elem. == "chunk") %>%
    dplyr::distinct(elemid.)

  ## Sentence level
  morphs <- purrr::imap(sentence_ids$elemid., function(sid, i) {

    ## Chunk level
    if (i < nrow(sentence_ids)) {
      targets_chunk_ids <- chunk_ids$elemid. %>%
        purrr::keep(sid <= .) %>%
        purrr::keep(. < sentence_ids$elemid.[i + 1])
    } else {
      targets_chunk_ids <- chunk_ids$elemid. %>%
        purrr::keep(sid <= .)
    }

    purrr::imap_dfr(targets_chunk_ids, function(cid, idx) {

      ## Parse morphs
      if (idx < length(targets_chunk_ids)) {
        df <- fxml %>%
          as.data.frame(stringsAsFactors = FALSE) %>%
          flatxml::fxml_getChildren(cid) %>%
          purrr::keep(cid <= .) %>%
          purrr::keep(. < targets_chunk_ids[idx + 1]) %>%
          purrr::map_dfr(function(morph_ids) {
            tok_id <- fxml %>%
              as.data.frame(stringsAsFactors = FALSE) %>%
              flatxml::fxml_getAttribute(morph_ids, "id")
            ne_value <- fxml %>%
              as.data.frame(stringsAsFactors = FALSE) %>%
              flatxml::fxml_getAttribute(morph_ids, "ne")
            surface_form <- fxml %>%
              as.data.frame(stringsAsFactors = FALSE) %>%
              flatxml::fxml_getValue(morph_ids)
            morph <- fxml %>%
              as.data.frame(stringsAsFactors = FALSE) %>%
              flatxml::fxml_getAttribute(morph_ids, "feature") %>%
              stringr::str_split(",", simplify = TRUE) %>%
              as.data.frame(stringsAsFactors = FALSE)
            tibble::tibble(
              chunk_id = cid,
              tok_id = as.numeric(tok_id),
              ne_value = ne_value,
              surface_form = surface_form,
            ) %>%
              dplyr::bind_cols(morph) %>%
              return()
          })
      } else {
        df <- fxml %>%
          as.data.frame(stringsAsFactors = FALSE) %>%
          flatxml::fxml_getChildren(cid) %>%
          purrr::keep(cid <= .) %>%
          purrr::map_dfr(function(morph_ids) {
            tok_id <- fxml %>%
              as.data.frame(stringsAsFactors = FALSE) %>%
              flatxml::fxml_getAttribute(morph_ids, "id")
            ne_value <- fxml %>%
              as.data.frame(stringsAsFactors = FALSE) %>%
              flatxml::fxml_getAttribute(morph_ids, "ne")
            surface_form <- fxml %>%
              as.data.frame(stringsAsFactors = FALSE) %>%
              flatxml::fxml_getValue(morph_ids)
            morph <- fxml %>%
              as.data.frame(stringsAsFactors = FALSE) %>%
              flatxml::fxml_getAttribute(morph_ids, "feature") %>%
              stringr::str_split(",", simplify = TRUE) %>%
              as.data.frame(stringsAsFactors = FALSE)
            tibble::tibble(
              chunk_id = cid,
              tok_id = as.numeric(tok_id),
              ne_value = ne_value,
              surface_form = surface_form,
            ) %>%
              dplyr::bind_cols(morph) %>%
              return()
          })
      }

      ## Set colnames
      if (ncol(df) < 13) {
        df <- dplyr::bind_cols(
          df,
          data.frame(
            a = c(NA_character_),
            b = c(NA_character_),
            stringsAsFactors = FALSE
          )
        )
      }
      colnames(df) <-
        c(
          "chunk_idx",
          "tok_idx",
          "ne_value",
          "Surface",
          "POS1",
          "POS2",
          "POS3",
          "POS4",
          "X5StageUse1",
          "X5StageUse2",
          "Original",
          "Yomi1",
          "Yomi2"
        )
      return(dplyr::mutate(df, dplyr::across(where(is.character), ~ dplyr::na_if(., "*"))))
    })
  })

  ## Parse attributes of elements
  attributes <- purrr::map_dfr(chunk_ids$elemid., function(id) {
    chunk_ids <- fxml %>%
      as.data.frame(stringsAsFactors = FALSE) %>%
      tidyr::drop_na(elem., elemid., attr., value.) %>%
      dplyr::distinct(elemid.) %>%
      dplyr::filter(elemid. == id)
    value <- fxml %>%
      as.data.frame(stringsAsFactors = FALSE) %>%
      tidyr::drop_na(elem., elemid., attr., value.) %>%
      flatxml::fxml_getAttributesAll(id)
    return(tibble::tibble(
      chunk_idx = chunk_ids$elemid.,
      D1 = value[["id"]],
      D2 = value[["link"]],
      rel = value[["rel"]],
      score = value[["score"]],
      head = value[["head"]],
      func = value[["func"]]
    ))
  })

  return(R6_CabochaR$new(attributes, morphs))
}
