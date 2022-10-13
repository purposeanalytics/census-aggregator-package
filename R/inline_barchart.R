#' @export
inline_barchart <- function(data, format = "proportion") {
  if (format == "proportion") {
    data <- data %>%
      dplyr::mutate(
        value = .data$value_proportion,
        value_fmt = scales::percent(.data$value_proportion, accuracy = 0.1),
        value = .data$value*100
      )
  } else if (format == "dollar") {
    data <- data %>%
      dplyr::mutate(
        value_fmt = scales::dollar(.data$value, accuracy = 1)
      )
  }

  # Coalesce NAs to 0 for bar
  data <- data %>%
    dplyr::mutate(
      value = dplyr::coalesce(.data$value, 0)
    )

  data <- data %>%
    dplyr::mutate(hist = .data$value) %>%
    dplyr::select(.data$label, .data$hist, .data$value_fmt) %>%
    dplyr::arrange(.data$label)

  # Scale bars if data is a proportion
  scale_bars <- format == "proportion"

  data %>%
    gt::gt() %>%
    gtExtras::gt_plt_bar_pct(hist, scaled = scale_bars, fill = "grey", background = "transparent") %>%
    # Coalesce formatted NA to em dash
    gt::sub_missing(columns = value_fmt) %>%
    gt::cols_width(hist ~ 200) %>%
    gt::cols_align(align = "left", columns = label) %>%
    gt::tab_options(
      table.width = "100%",
      column_labels.hidden = TRUE,
      table_body.border.top.color = "transparent",
      table_body.border.bottom.color = "transparent",
      table.font.names = "Lato"
    )
}
