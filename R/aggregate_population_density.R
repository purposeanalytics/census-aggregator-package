aggregate_population_density <- function(data) {
  # Filter for population and area
  population_and_area_data <- data %>%
    dplyr::filter(stringr::str_detect(.data$label, "Population, ") |
      .data$label == "Land area in square kilometres")

  # Check it contains the right fields - only ONE population field allowed

  # Aggregate each separately
  population_and_area_data <- population_and_area_data %>%
    dplyr::mutate(label_short = ifelse(.data$label == "Land area in square kilometres", "area", "population")) %>%
    split(.$label_short) %>%
    purrr::map_dfr(aggregate_census_variables, .id = "label_short")

  population_data <- population_and_area_data %>%
    dplyr::filter(.data$label_short == "population")
  area_data <- population_and_area_data %>%
    dplyr::filter(.data$label_short == "area")

  # Derive population density
  population_data %>%
    dplyr::left_join(area_data, by = c("type", "units", "aggregation", "aggregation_type"), suffix = c("_population", "_area")) %>%
    dplyr::mutate(
      value = .data$value_population / .data$value_area,
      label = "Population density per square kilometre",
      # TODO get year
      details = "CA 2016 Census; Population and Dwellings; Population density per square kilometre"
    ) %>%
    dplyr::select(.data$type, .data$label, .data$units, .data$aggregation, .data$aggregation_type, .data$details, .data$value)
}
