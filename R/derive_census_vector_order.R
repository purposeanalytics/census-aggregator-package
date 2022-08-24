#' Derive census vector order
#'
#' Derives the order census vectors should go in, either by using their vector numbering (semantic ordering) or by their values. Returns \code{label} in the data as an ordered factor.
#'
#' @param data Census data, aggregated via \code{\link{aggregate_census_vectors}}
#' @param by_value Whether the ordering is by the value (TRUE) or by the vector numbering (FALSE). Defaults to FALSE.
#'
#' @export
#' @examples
#' # TODO
derive_census_vector_order <- function(data, by_value = FALSE) {

  if (by_value) {
    data %>%
      dplyr::mutate(label = forcats::fct_reorder(.data$label, .data$value, .desc = TRUE))
  } else {
    data %>%
      tidyr::separate(.data$vector, into = c("v", "dataset", "order"), sep = "_", remove = FALSE) %>%
      dplyr::mutate(
        label = forcats::fct_reorder(.data$label, .data$order)
      )
  }
}
