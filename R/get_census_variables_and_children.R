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
get_census_variables_and_children <- function(dataset = "CA16", regions, level, variables) {

  # Check access to internet
  check_internet()

  # Get list of census vectors for given data set
  vectors <- cancensus::list_census_vectors(dataset)

  # Start a list of census vectors and all their children
}

census_vector_is_parent <- function(census_vectors, vector) {
  vector_children <- census_vectors %>%
    dplyr::filter(parent_vector == !!vector)

  is_parent <- nrow(vector_children) > 0

  is_parent
}
