aggregate_census_variables <- function(data) {

  # Check for necessary columns - units, aggregation_type, geo_uid, vector, value, highest_parent_vector
  check_data(data)

  # Make combined field for units and aggregation and split on it
  data <- data %>%
    dplyr::mutate(
      units_aggregation = paste0(.data$units, "_", .data$aggregation_simplified) %>%
        split(.$units_aggregation)
    )

  # Iterate through and aggregate

  purrr::imap_dfr
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
  "Number", "Average", "aggregate_number_average", "Number_Average",
  "Ratio", "Average", "aggregate_ratio_average", "Ratio_Average",
  "Percentage (0-100)", "Average", "aggregate_percentage_average", "Percentage (0-100)_Average",
  "Currency", "Median", "aggregate_currency_median", "Currency_Median",
  "Currency", "Average", "aggregate_currency_average", "Currency_Average"
) %>%
  split(.$units_aggregation)

aggregate_number_additive <- function(data) {
  aggregate_summary <- data %>%
    dplyr::group_by(highest_parent_vector, vector, type, label, units, parent_vector, aggregation, aggregation_type, details) %>%
    dplyr::summarise(
      value = sum(.data$value, na.rm = TRUE),
      .groups = "drop"
    )

  aggregate_summary_parents_only <- aggregate_summary %>%
    dplyr::filter(.data$vector == .data$highest_parent_vector) %>%
    dplyr::select(.data$highest_parent_vector, parent_value = .data$value)

  aggregate_summary %>%
    dplyr::left_join(aggregate_summary_parents_only, by = "highest_parent_vector") %>%
    dplyr::mutate(value_proportion = .data$value / .data$parent_value) %>%
    dplyr::select(-.data$parent_value)
}
