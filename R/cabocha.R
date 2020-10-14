#' Call cabocha -f3 command
#'
#' Call cabocha -f3 command via \code{system()}, then return results as a tibble.
#' It requires that CaboCha has already been installed and available.
#'
#' @param texts characters that you want to pass to CaboCha.
#' @param rcpath path to MECABRC if any.
#' @param force.utf8 boolean. If true, it reads cabocha output xml with UTF-8.
#'
#' @return R6 class object having fields and methods below.
#' \itemize{
#'   \item texts
#'   \item rcpath
#'   \item tbl: tibble that each rows represents a phrase.
#'   \item tbl2graph(): convert tbl to igraph graph object.
#'   \item plot(): simply plot the syntactic tree.
#' }
#'
#' @import R6
#' @import dplyr
#' @importFrom graphics plot
#' @importFrom xml2 read_xml
#' @importFrom xml2 xml_find_all
#' @importFrom xml2 xml_child
#' @importFrom xml2 xml_children
#' @importFrom purrr map_dfr
#' @importFrom purrr map_chr
#' @importFrom rvest html_attrs
#' @importFrom rvest html_text
#' @importFrom stringr str_c
#' @importFrom stringr str_replace
#' @importFrom tibble tibble
#' @importFrom igraph graph_from_data_frame
#' @importFrom igraph page.rank
#' @importFrom igraph V
#' @importFrom igraph layout_as_tree
#'
#' @export
CabochaTbl <- function(texts, rcpath = NULL, force.utf8 = FALSE) {
  ENC <- switch(.Platform$pkgType, "win.binary" = "CP932", "UTF-8")
  if (force.utf8) {
    ENC <- "UTF-8"
  }

  tmp_file_txt <- tempfile(fileext = ".txt")
  writeLines(texts, con = tmp_file_txt, useBytes = TRUE)

  if (!is.null(rcpath)) {
    system(paste(
      "cabocha -f3",
      file.path(tmp_file_txt),
      "-o",
      file.path(tempdir(), "data.xml"),
      "-b",
      rcpath
    ))
  } else {
    system(paste(
      "cabocha -f3",
      file.path(tmp_file_txt),
      "-o",
      file.path(tempdir(), "data.xml")
    ))
  }

  out <- readLines(file.path(tempdir(), "data.xml"), encoding = ENC)

  # Parse xml
  o <- xml2::read_xml(
    stringr::str_c(
      iconv(c("<sentences>", out, "</sentences>"), from = ENC, to = "UTF-8"),
      sep = "",
      collapse = ""
    )
  )

  # Clean up
  unlink(tmp_file_txt)

  # xml2df
  chunks <- o %>%
    xml2::xml_find_all(".//sentence") %>%
    xml2::xml_children()

  df <- purrr::map_dfr(chunks, function(chunk) {
    info <- rvest::html_attrs(chunk) %>%
      unlist()

    morphs <- xml2::xml_children(chunk) %>%
      purrr::map_chr(~ rvest::html_text(.)) %>%
      stringr::str_c(collapse = "")

    tibble::tibble(
      id = info["id"],
      link = info["link"],
      score = info["score"],
      morphs = morphs
    ) %>%
      return()
  })

  CabochaTbl <- R6::R6Class("CabochaTbl",
    public = list(
      texts = NULL,
      rcpath = NULL,
      tbl = NULL,
      initialize = function(texts, rcpath, tbl) {
        self$texts <- texts
        self$rcpath <- rcpath
        self$tbl <- tbl
      },
      tbl2graph = function(df = self$tbl, directed = TRUE) {
        tail <- length(df$id)
        to <- stringr::str_replace(df$link, "-1", as.character(tail))
        vertices <- tibble::tibble(
          name = c(df$id, as.character(tail)),
          morph = c(df$morphs, "EOS")
        )
        relations <- tibble::tibble(
          from = df$id,
          to = to,
          score = df$score
        )
        g <- igraph::graph_from_data_frame(relations,
          directed = directed,
          vertices = vertices
        )
        return(g)
      },
      plot = function(g = self$tbl2graph(), directed = TRUE) {
        pagerank <- igraph::page.rank(g, directed = directed)
        g %>%
          plot(
            vertex.size = pagerank$vector * 50,
            vertex.color = "steelblue",
            vertex.label = igraph::V(g)$morph,
            vertex.label.cex = 0.8,
            vertex.label.color = "black",
            edge.width = 0.4,
            edge.arrow.size = 0.4,
            edge.color = "gray80",
            layout = igraph::layout_as_tree(g, mode = "in", flip.y = FALSE)
          )
      }
    )
  )

  tbl <- CabochaTbl$new(texts, rcpath, df)
  return(tbl)
}

#' Call cabocha -f3 command
#'
#' Call cabocha -f3 command via \code{system()}, then return results as a flat XML.
#' It requires that CaboCha has already been installed and available.
#'
#' @param texts characters that you want to pass to CaboCha.
#' @param rcpath path to MECABRC if any.
#' @param as.tibble boolean. If false, then return flatXML dataframe.
#' @param force.utf8 boolean. If true, it reads cabocha output xml with UTF-8.
#' @param ... other arguments are passed to \code{tibble::as_tibble()}.
#'
#' @return flat XML made by \code{flatxml::fxml_importXMLFlat(CaboChaOutputXML)}
#'
#' @importFrom readr write_lines
#' @importFrom flatxml fxml_importXMLFlat
#' @importFrom tibble as_tibble
#' @importFrom dplyr %>%
#' @export
cabochaFlatXML <- function(texts,
                           rcpath = NULL,
                           as.tibble = FALSE,
                           force.utf8 = FALSE,
                           ...) {
  ENC <- switch(.Platform$pkgType, "win.binary" = "CP932", "UTF-8")
  if (force.utf8) {
    ENC <- "UTF-8"
  }

  tmp_file_txt <- tempfile(fileext = ".txt")
  writeLines(texts, con = tmp_file_txt, useBytes = TRUE)

  if (!is.null(rcpath)) {
    system(paste(
      "cabocha -f3 -n 1",
      file.path(tmp_file_txt),
      "-o",
      file.path(tempdir(), "data.xml"),
      "-b",
      rcpath
    ))
  } else {
    system(paste(
      "cabocha -f3 -n 1",
      file.path(tmp_file_txt),
      "-o",
      file.path(tempdir(), "data.xml")
    ))
  }

  out <- readLines(file.path(tempdir(), "data.xml"), encoding = ENC)
  tmp <- tempfile(fileext = ".xml")

  readr::write_lines("<sentences>", tmp)
  readr::write_lines(iconv(out, from = ENC, to = "UTF-8"), tmp, append = TRUE)
  readr::write_lines("</sentences>", tmp, append = TRUE)

  flatdf <- flatxml::fxml_importXMLFlat(file.path(tmp))

  unlink(tmp_file_txt)
  unlink(tmp)

  if (as.tibble) {
    flatdf %>%
      tibble::as_tibble(...) %>%
      return()
  } else {
    flatdf %>%
      return()
  }
}
