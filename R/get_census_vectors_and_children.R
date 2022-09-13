#' Get census vectors and children
#'
#' Get data for census vectors and all of their children (and their childrens' children, etc).
#'
#' @param dataset The dataset to query vectors from. Defaults to "CA16", the 2016 Canadian Census.
#' @inheritParams cancensus::get_census
#' @param vectors An R vector containing the vector short codes for the Census vectors to download. Vector short codes can be found via the \code{vector} field of \code{\link{census_vectors}}.
#'
#' @export
#'
#' @examples
#' get_census_vectors_and_children(
#'   regions = list(CSD = c("3520005", "3521005", "3521010")),
#'   level = "CSD", vectors = c("v_CA16_404", "v_CA16_548")
#' )
get_census_vectors_and_children <- function(dataset = "CA16", regions = "Regions", level, vectors, quiet = TRUE) {

  # Check access to internet
  check_internet()

  # Get all child vectors for each vector
  children_vectors <- census_vectors %>%
    purrr::set_names() %>%
    purrr::map_dfr(cancensus::child_census_vectors,
      keep_parent = TRUE,
      .id = "highest_parent_vector"
    )

  # Get data for each vector
  census_vectors_data <- get_and_tidy_census_data(
    dataset = dataset,
    regions = regions,
    level = level,
    vectors = unique(children_vectors[["vector"]]),
    quiet = quiet
  )

  # Add label and units, derive "aggregation_type"
  children_vectors %>%
    dplyr::left_join(census_vectors_data, by = "vector") %>%
    dplyr::distinct() %>%
    derive_aggregation_type()
}

get_and_tidy_census_data <- function(dataset, regions, level, vectors, labels = "short", quiet = TRUE) {
  cancensus::get_census(dataset,
    regions = regions,
    level = level,
    vectors = vectors,
    labels = "short",
    quiet = quiet
  ) %>%
    dplyr::select(
      geo_uid = .data$GeoUID,
      population = .data$Population, households = .data$Households,
      dplyr::all_of(vectors)
    ) %>%
    tidyr::pivot_longer(dplyr::all_of(vectors), names_to = "vector")
}
