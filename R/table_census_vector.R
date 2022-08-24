#' @export
table_census_vector <- function(data) {
  data %>%
    dplyr::select(label, value_proportion) %>%
    dplyr::mutate(dplyr::across(value_proportion, scales::percent, 0.1)) %>%
    knitr::kable(align = "lr", col.names = NULL) %>%
    kableExtra::column_spec(column = 1, bold = TRUE) %>%
    kableExtra::kable_styling(full_width = TRUE)
}
