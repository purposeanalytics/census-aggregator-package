#' Get census variables and children
#'
#' Get data for census variables and all of their children (and their childrens' children, etc).
#'
#' @param dataset The dataset to query variables from. Defaults to "CA16", the 2016 Canadian Census.
#' @param regions A named list of census regions to retrieve, e.g. ... TODO - do we want to offer all the same options as cancensus? Probably yes!
#' @param level The census aggregation level to retrieve, defaults to ... TODO - do we want to offer all the same options as cancensus? Probably yes!
#' @param variables An R vector containing the variable short codes for the Census variables to download. Variable short codes can be found via \link[cancensus]{list_census_vectors}.
#'
#' @return
#' @export
#'
#' @examples {
#'   get_census_variables_and_children(variables = c("v_CA16_404", "v_CA16_548"))
#' }
get_census_variables_and_children <- function(dataset = "CA16",
                                              # regions, level,
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

  # Get data for each vector - just do for Canada for now, don't actually set region / level
  census_vectors <- get_and_tidy_census_data(
    dataset = dataset,
    vectors = children_vectors[["vector"]]
  )

  # Add label and units
  children_vectors %>%
    dplyr::left_join(census_vectors, by = "vector")
}

get_and_tidy_census_data <- function(dataset,
                                     # regions,
                                     # level,
                                     vectors,
                                     labels = "short") {
  cancensus::get_census(dataset,
    regions = list(C = "01"),
    level = "Regions",
    vectors = vectors,
    labels = "short"
  ) %>%
    dplyr::select(geo_uid = GeoUID, dplyr::all_of(vectors)) %>%
    tidyr::pivot_longer(dplyr::all_of(vectors), names_to = "vector")
}
