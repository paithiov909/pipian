#' @noRd
#' @keywords internal
resetEncoding <- function(chr, encoding = "UTF-8") {
  Encoding(chr) <- encoding
  return(chr)
}

#' yet another part-of-speech tagger
#'
#' \code{posSimple} returns part-of-speech (POS) tagged morphemes of the sentence as a simple data.frame.
#'
#' This function returns morphemes and their features as a simple data.frame.
#' If only a character vector provided as `into`, the function separates every feature with `,`
#' into the dictionary-specific format.
#'
#' It is useful when you want to check all features of morphemes and then filter, remove or count
#' some morphemes by their features that are not available in output of \code{pos} and \code{posParallel}.
#'
#' @param sentence Character vector.
#' @param into NULL or character vector. If not NULL, this argument is passed to \code{tidyr::separate}
#' @param sys_dic A location of system MeCab dictionary. The default value is "".
#' @param user_dic A location of user-specific MeCab dictionary. The default value is "".
#' @return data.frame
#'
#' @examples
#' \dontrun{
#' sentence <- c("some UTF-8 texts")
#' posSimple(sentence)
#' # Parse features of Japanese IPA dictionary.
#' posSimple(sentence, into = c("POS1", "POS2", "POS3", "POS4", "X5StageUse1", "X5StageUse2", "Original", "Yomi1", "Yomi2"))
#' }
#' @export
posSimple <- function(sentence,
                      into = NULL,
                      sys_dic = "",
                      user_dic = "") {
  if (typeof(sentence) != "character") {
    if (typeof(sentence) == "factor") {
      stop("The type of input sentence is a factor. Please typesetting it with as.character().")
    } else {
      stop("The function gets a character vector only.")
    }
  }

  if (!isBlank(getOption("mecabSysDic"))) sys_dic <- getOption("mecabSysDic")

  sentence <- stringi::stri_enc_toutf8(sentence)
  sys_dic <- paste0(sys_dic, collapse = "")
  user_dic <- paste0(user_dic, collapse = "")

  result <- posApplyDFRcpp(sentence, sys_dic, user_dic) %>%
    purrr::map(~ tibble::rowid_to_column(., "token_id")) %>%
    purrr::imap_dfr(~ data.frame(doc_id = .y, .x)) %>%
    dplyr::mutate(dplyr::across(where(is.character), ~ resetEncoding(.)))
  if (!is.null(into)) {
    result <- result %>%
      tidyr::separate(
        col = "feature",
        into = into,
        sep = ",",
        fill = "right"
      ) %>%
      dplyr::mutate(dplyr::across(where(is.character), ~ dplyr::na_if(., "*")))
  }

  return(result)
}
