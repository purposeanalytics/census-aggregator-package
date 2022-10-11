#' Aggregate estimated median income
#'
#' Estimate median income using income buckets, rounded to the nearest $1,000
#'
#' @param data Data containing income buckets and total count income is based on
#'
#' @export
#'
#' @examples
aggregate_estimated_median_income <- function(data) {

  # Get count that the median is based on
  households_with_total_income <- data %>%
    dplyr::filter(.data$vector == .data$highest_parent_vector) %>%
    dplyr::pull(.data$value)

  # If count is less than 1000, return NA - too small to accurately estimate
  # Or if NA (suppressed)

  if (is.na(households_with_total_income) | households_with_total_income < 1000) {
    return(tibble::tibble(value = NA))
  }

  # Take half of count, and round up
  median_index <- ceiling(households_with_total_income / 2)

  # Convert vector labels into numerical ranges
  household_income_ranges <- data %>%
    dplyr::filter(.data$vector != .data$highest_parent_vector) %>%
    dplyr::distinct(.data$label) %>%
    parse_income_vectors()

  # Get cumulative count in each bucket (vector), and flag which are before / after the median index
  buckets_vs_median <- data %>%
    dplyr::filter(.data$vector != .data$highest_parent_vector) %>%
    dplyr::left_join(household_income_ranges, by = "label") %>%
    dplyr::select(.data$label, .data$min, .data$max, .data$value) %>%
    dplyr::mutate(
      value_cumulative = cumsum(.data$value),
      previous_value_cumulative = dplyr::lag(.data$value_cumulative),
      before_median_index = .data$value_cumulative < median_index
    )

  # Get the bucket that includes the median index (the first bucket that is not less than it)
  # And see how "far" into the bucket the median is, by taking the median index and subtracting the previous bucket count
  # Then, estimate the median $$ by moving into the bucket proportionally to how far in the median is
  estimated_median <- buckets_vs_median %>%
    dplyr::filter(!.data$before_median_index) %>%
    dplyr::filter(dplyr::row_number() == 1) %>%
    dplyr::mutate(
      left_before_median_index = median_index - .data$previous_value_cumulative,
      prop_of_bucket = .data$left_before_median_index / .data$value,
      value_from_bucket = (.data$max - .data$min) * .data$prop_of_bucket,
      estimated_median = .data$min - 1 + .data$value_from_bucket
    ) %>%
    dplyr::pull(.data$estimated_median)


  # If the estimate is NA because the bucket is 200,000
  # TODO
  # Just 200,000 for now
  if (is.na(estimated_median)) {
    estimated_median <- 200000
  }

  # Round to the nearest 1000
  tibble::tibble(value = round_to(estimated_median))
}

parse_income_vectors <- function(data) {
  data %>%
    tidyr::separate(.data$label, into = c("min", "max"), sep = " to ", remove = FALSE, fill = "right") %>%
    dplyr::select(.data$label, .data$min, .data$max) %>%
    dplyr::mutate(
      min = dplyr::case_when(
        stringr::str_starts(.data$label, "Under") ~ NA_character_,
        stringr::str_ends(.data$label, "and over") ~ stringr::str_remove(.data$label, " and over"),
        TRUE ~ .data$min
      ),
      max = dplyr::case_when(
        stringr::str_starts(.data$label, "Under") ~ stringr::str_remove(.data$label, "Under "),
        stringr::str_ends(.data$label, "and over") ~ NA_character_,
        TRUE ~ .data$max
      ),
      dplyr::across(c(.data$min, .data$max), readr::parse_number)
    )
}

# From SO https://stackoverflow.com/a/32508105
round_to <- function(x, y = 1000) {
  if ((y - x %% y) <= x %% y) {
    x + (y - x %% y)
  } else {
    x - (x %% y)
  }
}
