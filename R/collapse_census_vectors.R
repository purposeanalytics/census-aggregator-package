#' Collapse census vectors
#'
#' Collapse several census vectors into a single vector
#'
#' @param data Census data, from e.g. \link[cancensus]{list_census_vectors} or \link{get_census_vectors_and_children}
#' @param vectors A data frame of existing census vectors (\code{vector}) and new "vectors" (\code{new_vector}) which they will be collapsed into. The \code{vector} field in \code{data} will be replaced with \code{new_vector}. If relevant, so will the \code{label} field, and the \code{details} field will have the label element replaced with the new vector element.
#' @param aggregate Whether to aggregate (sum) existing values. Defaults to FALSE.
#'
#' @export
#'
#' @examples
#' library(dplyr)
#' library(cancensus)
#'
#' couples_with_children <- tibble(vector = c("v_CA21_502", "v_CA21_505"), new_vector = "Couples with children")
#'
#' list_census_vectors("CA21") %>%
#'   collapse_census_vectors(couples_with_children) %>%
#'   filter(vector %in% couples_with_children[["new_vector"]])
collapse_census_vectors <- function(data, vectors, aggregate = FALSE) {
  data <- data %>%
    dplyr::left_join(vectors, by = "vector") %>%
    dplyr::mutate(
      vector = dplyr::coalesce(.data$new_vector, .data$vector)
    )

  if ("details" %in% names(data)) {
    data <- data %>%
      dplyr::mutate(details = ifelse(is.na(.data$new_vector), .data$details, stringr::str_replace(.data$details, .data$label, .data$new_vector)))
  }

  if ("label" %in% names(data)) {
    data <- data %>%
      dplyr::mutate(label = dplyr::coalesce(.data$new_vector, .data$label))
  }

  data <- data %>%
    dplyr::select(-.data$new_vector)

  if (aggregate) {
    data_without_new <- data %>%
      dplyr::filter(!.data$vector %in% vectors[["new_vector"]])

    data_only_new <- data %>%
      dplyr::filter(.data$vector %in% vectors[["new_vector"]])

    data_only_new <- data_only_new %>%
      dplyr::group_by(dplyr::across(-.data$value)) %>%
      dplyr::summarise(
        value = sum(.data$value),
        .groups = "drop"
      )

    data <- dplyr::bind_rows(
      data_without_new,
      data_only_new
    )
  }

  data
}
