#' Collapse census vectors
#'
#' Collapse several census vectors into a single vector
#'
#' @param data Census data, from e.g. \link[cancensus]{list_census_vectors} or \link{get_census_vectors_and_children}
#' @param vectors A data frame of existing census vectors (\code{vector}) and new "vectors" (\code{new_vector}) which they will be collapsed into. Both the \code{vector} and \code{label} fields in \code{data} will be replaced with \code{new_vector}, and the \code{details} field will have the label element replaced with the new vector element.
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
collapse_census_vectors <- function(data, vectors) {
  data %>%
    dplyr::left_join(vectors, by = "vector") %>%
    dplyr::mutate(
      vector = dplyr::coalesce(new_vector, vector),
      details = ifelse(is.na(new_vector), details, stringr::str_replace(details, label, new_vector)),
      label = dplyr::coalesce(new_vector, label)
    ) %>%
    dplyr::select(-new_vector) %>%
    dplyr::distinct()
}