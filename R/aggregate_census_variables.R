#' Aggregate census variables
#'
#' Automatically aggregate census variables from multiple geographies, based on the type of data. See Details.
#'
#' The following types of vectors are supported:
#'
#' ## Units: Number, Aggregation Type: Additive
#'
#' The \code{value} is derived by summing all of the \code{value}s for each vector, across geographies. The result is a count (e.g. population, households). An additional field, \code{value_proportion}, is derived, describing what proportion of the total count (e.g. of population, households) from the highest parent vector falls within each child vector.
#'
#' ## Units: Percentage (0-100), Aggregation Type: Average
#'
#' ## Units: Currency, Aggregation Type: Average
#'
#' @param data Data for census variables, from \code{\link{get_census_variables_and_children}}
#'
#' @export
#'
#' @examples
#' get_census_variables_and_children(
#'   regions = list(CSD = c("3520005", "3521005")),
#'   level = "CSD",
#'   variables = c("v_CA16_401", "v_CA16_418")
#' ) %>%
#'   aggregate_census_variables()
aggregate_census_variables <- function(data) {

  # Check for necessary columns - units, aggregation_type, geo_uid, vector, value, highest_parent_vector
  check_data(data)

  # Make combined field for units and aggregation and split on it
  data <- data %>%
    dplyr::mutate(
      units_aggregation = paste0(.data$units, "_", .data$aggregation_type)
    )

  data <- split(data, data$units_aggregation)

  # Iterate through and aggregate

  purrr::imap_dfr(data, function(data, units_aggregation) {
    if (units_aggregation %in% names(units_and_aggregation_functions)) {
      # Aggregate if it is in the list of supported aggregations / functions
      func <- units_and_aggregation_functions[[units_aggregation]][["func"]]

      do.call(func, list(data = data))
    } else {
      # If not, do not aggregate and just warn / drop data
      units_aggregation_split <- stringr::str_split(units_aggregation, "_", simplify = TRUE)
      vectors_dropped <- paste0(unique(data[["vector"]]), collapse = ", ")
      warning(
        "Aggregation for vectors with ",
        "`units: ", units_aggregation_split[[1]], "` ",
        "and ",
        "`aggregation_type: ", units_aggregation_split[[2]], "` ",
        "is not available. ",
        "Vectors with this combination have been dropped: ", vectors_dropped, ".",
        call. = FALSE
      )

      tibble::tibble()
    }
  })
}


check_data <- function(data) {
  columns <- c("units", "aggregation_type", "geo_uid", "vector", "value", "highest_parent_vector")

  contains_necessary_columns <- purrr::map_lgl(columns, contains_column, data)

  if (!all(contains_necessary_columns)) {
    stop("data must contain all columns:",
      paste(columns, collapse = ", "),
      ". It should be the output from `get_census_variables_and_children()`.",
      call. = FALSE
    )
  }
}

contains_column <- function(column, data) {
  column %in% names(data)
}

units_and_aggregation_functions <- tibble::tribble(
  ~units, ~aggregation, ~func, ~units_aggregation,
  "Number", "Additive", "aggregate_number_additive", "Number_Additive",
  # "Number", "Average", "aggregate_number_average", "Number_Average",
  # "Ratio", "Average", "aggregate_ratio_average", "Ratio_Average",
  "Percentage (0-100)", "Average", "aggregate_percentage_average", "Percentage (0-100)_Average",
  # "Currency", "Median", "aggregate_currency_median", "Currency_Median",
  "Currency", "Average", "aggregate_currency_average", "Currency_Average"
) %>%
  split(.$units_aggregation)

aggregate_number_additive <- function(data) {

  # Total value is derived by summing value

  aggregate_summary <- data %>%
    dplyr::group_by(
      .data$highest_parent_vector, .data$vector, .data$type, .data$label, .data$units,
      .data$parent_vector, .data$aggregation, .data$aggregation_type, .data$details
    ) %>%
    dplyr::summarise(
      value = sum(.data$value, na.rm = TRUE),
      .groups = "drop"
    )

  # Proportion is from the parent vector's total, not the sum of the population (since it does not always match)

  aggregate_summary_parents_only <- aggregate_summary %>%
    dplyr::filter(.data$vector == .data$highest_parent_vector) %>%
    dplyr::select(.data$highest_parent_vector, parent_value = .data$value)

  aggregate_summary %>%
    dplyr::left_join(aggregate_summary_parents_only, by = "highest_parent_vector") %>%
    dplyr::mutate(value_proportion = .data$value / .data$parent_value) %>%
    dplyr::select(-.data$parent_value)
}

aggregate_number_average <- function() {

}

aggregate_ratio_average <- function() {

}

aggregate_percentage_average <- function(data) {

  # Multiply population by value (/100), then sum and divide by total population in vector

  data %>%
    dplyr::mutate(value_proportion = .data$value / 100) %>%
    dplyr::group_by(
      .data$highest_parent_vector, .data$vector, .data$type, .data$label, .data$units,
      .data$parent_vector, .data$aggregation, .data$aggregation_type, .data$details
    ) %>%
    dplyr::summarise(
      value = sum(.data$population * .data$value_proportion) / sum(.data$population),
      .groups = "drop"
    )
}

aggregate_currency_median <- function() {

}

aggregate_currency_average <- function(data) {

  # Get "total value" (value * population) for each, then sum within vector and divide by total Population

  data %>%
    dplyr::mutate(value_total = .data$value * .data$population) %>%
    dplyr::group_by(
      .data$highest_parent_vector, .data$vector, .data$type, .data$label, .data$units,
      .data$parent_vector, .data$aggregation, .data$aggregation_type, .data$details
    ) %>%
    dplyr::summarise(
      value = sum(.data$value_total) / sum(.data$population),
      .groups = "drop"
    )
}
