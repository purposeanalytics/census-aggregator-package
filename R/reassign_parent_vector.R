#' Reassign parent vector
#'
#' Update the parent (and highest parent, if relevant) for supplied vectors. Useful for piping into \code{\link{aggregate_census_vectors}}, which often uses the parent vector as a denominator. Optionally, if \code{new_label_short} is provided in \code{vectors}, the \code{label_short} field of \code{data} will also be replaced.
#'
#' @param data Census data, from e.g. \link[cancensus]{list_census_vectors} or \link{get_census_vectors_and_children}
#' @param vectors A tibble containing \code{vector} and \code{new_parent_vector} for setting a vector's new parent vector in \code{data}. Can optionally include \code{new_label_short} to also replace the \code{label_short} field.
#'
#' @export
#'
#' @examples
#' # TODO
reassign_parent_vector <- function(data, vectors) {
  data <- data %>%
    dplyr::left_join(vectors, by = "vector") %>%
    dplyr::mutate(parent_vector = dplyr::coalesce(.data$new_parent_vector, .data$parent_vector))

  if ("highest_parent_vector" %in% names(data)) {
    data <- data %>%
      dplyr::mutate(highest_parent_vector = dplyr::coalesce(.data$new_parent_vector, .data$highest_parent_vector))
  }

  if ("label_short" %in% names(data)) {
    data <- data %>%
      dplyr::mutate(label_short = dplyr::coalesce(.data$new_label_short, .data$label_short)) %>%
      dplyr::select(-.data$new_label_short)
  }

  data %>%
    dplyr::select(-.data$new_parent_vector)
}
