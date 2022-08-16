#' Derive census vector order
#'
#' Derives the order census vectors should go in, either by using their vector numbering (semantic ordering) or by their values. Returns \code{label} in the data as an ordered factor.
#'
#' @param data
#' @param by_value Whether the ordering is by the value (TRUE) or by the vector numbering (FALSE). Defaults to FALSE.
#'
#' @examples
derive_census_vector_order <- function(data, by_value = FALSE) {

  if (by_value) {
    data %>%
      dplyr::mutate(label = forcats::fct_reorder(label, value, .desc = TRUE))
  } else {
    data %>%
      tidyr::separate(vector, into = c("v", "dataset", "order"), sep = "_", remove = FALSE) %>%
      dplyr::mutate(
        label = forcats::fct_reorder(label, order)
      )
  }
}
