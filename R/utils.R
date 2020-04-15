#' Utility for parsing CaboCha output
#'
#' Pluck a value from feature attribute of CaboCha output tok.
#'
#' @param str strings representing feature attribute of CaboCha output tok.
#' @param idx index to pluck.
#'
#' @importFrom stringr str_split
#' @importFrom stringr str_c
#' @importFrom dplyr %>%
#' @export
pluckAttrs <- function(str, idx) {
  split <- stringr::str_split(str, ",")
  split %>%
    lapply(function(split) {
      return(split[[1]][[idx]])
    }) %>%
    unlist() %>%
    stringr::str_c(collapse = "") %>%
    return()
}

#' Utility for parsing CaboCha output
#'
#' convert flat XML into CabochaR compatible output.
#'
#' @param fxml flat XML that comes out from \code{cabochaFlatXML(as.tibble = FALSE)}
#'
#' @return R6 class object having fields and methods below.
#' \itemize{
#'   \item attributes: list of list. Each elements consist of the element id and attributes of chunk.
#'   \item morphs: list of tibble. Each elements represent morphemes of which the chunk is made.
#'   \item as.tibble(): return a tibble compatible with CabochaR output.
#' }
#'
#' @seealso \url{https://minowalab.org/cabochar/}
#'
#' @import R6
#' @import dplyr
#' @importFrom purrr map
#' @importFrom purrr map_dfr
#' @importFrom flatxml fxml_getChildren
#' @importFrom flatxml fxml_getAttribute
#' @importFrom flatxml fxml_getAttributesAll
#' @importFrom stringr str_split
#' @importFrom tibble tibble
#' @importFrom tidyr drop_na
#' @export
CabochaR <- function(fxml) {
  chunk_ids <- fxml %>%
    as.data.frame() %>%
    dplyr::filter(elem. == "chunk") %>%
    dplyr::distinct(elemid.)

  morphs <- purrr::map(chunk_ids$elemid., function(id) {
    df <- fxml %>%
      as.data.frame() %>%
      flatxml::fxml_getChildren(id) %>%
      purrr::map_dfr(function(morph_ids) {
        tok_id <- fxml %>%
          as.data.frame() %>%
          flatxml::fxml_getAttribute(morph_ids, "id")
        surface_form <- fxml %>%
          as.data.frame() %>%
          flatxml::fxml_getValue(morph_ids)
        morph <- fxml %>%
          as.data.frame() %>%
          flatxml::fxml_getAttribute(morph_ids, "feature") %>%
          stringr::str_split(",", simplify = TRUE) %>%
          as.data.frame(stringsAsFactors = FALSE)
        tibble::tibble(
          chunk_id = id,
          tok_id = as.numeric(tok_id),
          surface_form = surface_form
        ) %>%
          dplyr::bind_cols(morph) %>%
          return()
      })
    if (ncol(df) < 12) {
      df <- dplyr::bind_cols(
        df,
        data.frame(
          a = c(NA),
          b = c(NA),
          stringsAsFactors = FALSE
        )
      )
    }
    colnames(df) <-
      c(
        "chunk_id",
        "tok_id",
        "word",
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
    return(df)
  })

  CabochaR <- R6::R6Class(
    "CabochaR",
    public = list(
      attributes = NULL,
      morphs = NULL,
      initialize = function(attributes, morphs) {
        self$attributes <- attributes
        self$morphs <- morphs
      },
      as.tibble = function(attr = self$attributes, dfs = self$morphs) {
        purrr::imap_dfr(
          dfs,
          as_mapper(
            ~
            tibble::tibble(
              chunk_id = attr[[.y]][[1]],
              D1 = as.numeric(attr[[.y]][[2]][["id"]]),
              D2 = as.numeric(attr[[.y]][[2]][["link"]]),
              rel = attr[[.y]][[2]][["rel"]],
              score = as.double(attr[[.y]][[2]][["score"]]),
              head = as.numeric(attr[[.y]][[2]][["head"]]),
              func = as.numeric(attr[[.y]][[2]][["func"]])
            ) %>%
              dplyr::left_join(.x, by = "chunk_id") %>%
              return()
          )
        ) %>%
          return()
      }
    )
  )

  attributes <- purrr::map(chunk_ids$elemid., function(id) {
    chunk_ids <- fxml %>%
      as.data.frame() %>%
      tidyr::drop_na(elem., elemid., attr., value.) %>%
      dplyr::distinct(elemid.) %>%
      dplyr::filter(elemid. == id)
    attr <- fxml %>%
      as.data.frame() %>%
      tidyr::drop_na(elem., elemid., attr., value.) %>%
      flatxml::fxml_getAttributesAll(id)
    return(list(chunk_ids$elemid., attr))
  })
  obj <- CabochaR$new(attributes, morphs)

  return(obj)
}
