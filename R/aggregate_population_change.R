aggregate_population_change <- function(data) {

  # Filter for population data only, get year from each
  population_data <- data %>%
    dplyr::filter(stringr::str_detect(.data$label, "Population, ")) %>%
    tidyr::separate(.data$label,
      into = c("population_label", "population_year"),
      sep = ", ", remove = FALSE, convert = TRUE
    )

  # Check that data contains 2 population vectors
  n_population_vectors <- population_data %>%
    dplyr::filter(stringr::str_detect(label, "Population, ")) %>%
    dplyr::pull(label) %>%
    unique() %>%
    length()

  if (n_population_vectors != 2) {
    stop("Data must contain two distinct years of `Population` vectors to calculate population change.",
         call. = FALSE)
  }

  # Aggregate each separately
  population_data <- population_data %>%
    split(.$population_year) %>%
    purrr::map_dfr(aggregate_census_variables, .id = "population_year")

  population_data_min <- population_data %>%
    dplyr::filter(.data$population_year == min(.data$population_year))
  population_data_max <- population_data %>%
    dplyr::filter(.data$population_year != min(.data$population_year))

  # Calculate the change
  population_data_min %>%
    dplyr::left_join(population_data_max, by = c("type", "units", "aggregation", "aggregation_type"), suffix = c("_min", "_max")) %>%
    dplyr::mutate(
      value = (.data$value_max - .data$value_min) / .data$value_min,
      label = glue::glue("Population percentage change, {population_year_min} to {population_year_max}"),
      details = glue::glue("CA {population_year_max} Census; Population and Dwellings; Population percentage change,  {population_year_min} to {population_year_max}"),
      dplyr::across(c(.data$label, .data$details), as.character)
    ) %>%
    dplyr::select(.data$type, .data$label, .data$units, .data$aggregation, .data$aggregation_type, .data$details, .data$value)
}
