#' Get census variables and children
#'
#' Get data for census variables and all of their children (and their childrens' children, etc).
#'
#' @param dataset The dataset to query variables from. Defaults to "CA16", the 2016 Canadian Census.
#' @inheritParams cancensus::get_census
#' @param variables An R vector containing the variable short codes for the Census variables to download. Variable short codes can be found via \link[cancensus]{list_census_vectors}.
#'
#' @export
#'
#' @examples
#' get_census_variables_and_children(
#'  regions = list(CSD = c("3520005", "3521005", "3521010")),
#'  level = "CSD", variables = c("v_CA16_404", "v_CA16_548")
#' )
get_census_variables_and_children <- function(dataset = "CA16",
                                              regions = "Regions",
                                              level,
                                              variables) {

  # Check access to internet
  check_internet()

  # Get all child variables for each vector
  children_vectors <- variables %>%
    purrr::set_names() %>%
    purrr::map_dfr(cancensus::child_census_vectors,
      keep_parent = TRUE,
      .id = "highest_parent_vector"
    )

  # Get data for each vector
  census_vectors <- get_and_tidy_census_data(
    dataset = dataset,
    regions = regions,
    level = level,
    vectors = unique(children_vectors[["vector"]])
  )

  # Add label and units, derive "aggregation_type"
  children_vectors %>%
    dplyr::left_join(census_vectors, by = "vector") %>%
    dplyr::distinct() %>%
    dplyr::mutate(aggregation_type = stringr::str_remove(.data$aggregation, " of.*")) %>%
    dplyr::relocate(.data$aggregation_type, .after = .data$aggregation)
}

get_and_tidy_census_data <- function(dataset,
                                     regions,
                                     level,
                                     vectors,
                                     labels = "short") {
  cancensus::get_census(dataset,
    regions = regions,
    level = level,
    vectors = vectors,
    labels = "short"
  ) %>%
    dplyr::select(geo_uid = .data$GeoUID, population = .data$Population, dplyr::all_of(vectors)) %>%
    tidyr::pivot_longer(dplyr::all_of(vectors), names_to = "vector")
}
