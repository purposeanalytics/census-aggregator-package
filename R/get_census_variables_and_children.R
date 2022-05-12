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
get_census_variables_and_children <- function(dataset = "CA16",
                                              # regions, level,
                                              variables) {

  # Check access to internet
  check_internet()

  # Get census vectors for given dataset
  vectors <- cancensus::list_census_vectors(dataset)

  # Get all children vectors for each variable
  children_vectors <- variables %>%
    purrr::set_names() %>%
    purrr::map(~ census_vector_all_children(vectors, .x))

  # Get data for each vector - just do for Canada for now, don't actually set region / level
  children_vectors %>%
    purrr::map_dfr(~ get_and_tidy_census_data(dataset = dataset, vectors = .x),
      .id = "parent_vector"
    )
}

census_vector_children <- function(census_vectors, vector) {
  census_vectors %>%
    dplyr::filter(parent_vector %in% !!vector) %>%
    dplyr::pull(vector)
}

census_vector_is_parent <- function(census_vectors, vector) {
  vector_children <- census_vector_children(census_vectors, vector)

  length(vector_children) > 0
}

census_vector_all_children <- function(census_vectors, vector) {
  query_vectors <- vector
  data_vectors <- vector

  while (length(query_vectors) > 0) {
    children <- census_vector_children(census_vectors, query_vectors)

    data_vectors <- c(data_vectors, children)
    query_vectors <- children
  }

  data_vectors
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
    pivot_longer(dplyr::all_of(vectors), names_to = "vector")
}
