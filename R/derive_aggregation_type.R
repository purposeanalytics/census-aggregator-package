#' Derive aggregation type
#'
#' Derive `aggregation_type` field from data containing an `aggregation` field. This is a simplified version of the field, e.g. converting `aggregation = "Average of v_CA16_4890"` to `aggregation_type = "Average"`
#'
#' @param data Data containing a field `aggregation`, e.g. from \code{\link[cancensus]{list_census_vectors}}
#'
#' @export
#'
#' @examples
#' library(cancensus)
#'
#' list_census_vectors("CA16") %>%
#'   derive_aggregation_type()
derive_aggregation_type <- function(data) {
  data %>%
    dplyr::mutate(aggregation_type = stringr::str_remove(.data$aggregation, " of.*")) %>%
    dplyr::relocate(.data$aggregation_type, .after = .data$aggregation)
}
