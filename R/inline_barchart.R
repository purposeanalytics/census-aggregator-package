#' @export
inline_barchart <- function(data, format = "proportion") {
  if (format == "proportion") {
    data <- data %>%
      dplyr::mutate(
        count = scales::comma(.data$value),
        value = .data$value_proportion,
        value_fmt = scales::percent(.data$value_proportion, accuracy = 0.1),
        value = .data$value * 100
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
    dplyr::select(.data$label, tidyselect::any_of("count"), .data$value_fmt, .data$hist) %>%
    dplyr::arrange(.data$label)

  # Scale bars if data is a proportion
  scale_bars <- format == "proportion"

  # Add footnote if relevant
  footnote <- NULL

  if (any(stringr::str_detect(data[["label"]], "n.i.e."))) {
    footnote <- c(footnote, '"n.i.e." = not included elsewhere')
  }

  if (any(stringr::str_detect(data[["label"]], "n.o.s."))) {
    footnote <- c(footnote, '"n.o.s." = not otherwise specified')
  }

  # Add note about --- if suppressed
  if (any(is.na(data[["value_fmt"]]))) {
    footnote <- c(footnote, "&#8212; indicates data for one or more of the selected areas is not available or is suppressed due to confidentiality.")
  }

  if (!is.null(footnote)) {
    footnote <- paste(footnote, collapse = "; ")
    footnote <- paste("Note:", footnote)
  }

  table <- data %>%
    gt::gt() %>%
    gtExtras::gt_plt_bar_pct(hist, scaled = scale_bars, fill = "grey", background = "transparent") %>%
    # Coalesce formatted NA to em dash
    gt::sub_missing(columns = value_fmt) %>%
    gt::cols_align(align = "left", columns = label) %>%
    gt::cols_align(align = "right", columns = value_fmt) %>%
    gt::tab_options(
      table.width = "100%",
      column_labels.hidden = TRUE,
      table_body.border.top.color = "transparent",
      table.font.names = "Lato"
    )

  if (format == "proportion") {
    table <- table %>%
      gt::cols_width(label ~ 175, count ~ 75, value_fmt ~ 75, hist ~ 100)
  } else {
    table <- table %>%
      gt::cols_width(label ~ 250, value_fmt ~ 75, hist ~ 100)
  }

  # If there is a footnote, keep the table_body bottom border and remove the overall table one
  # If there is NO footnote, remove the table_body one

  if (!is.null(footnote)) {
    table <- table %>%
      gt::tab_footnote(gt::html(footnote), placement = "left") %>%
      gt::tab_style(
        style = list(gt::cell_text(style = "italic")),
        locations = gt::cells_footnotes()
      ) %>%
      gt::tab_options(
        table.border.bottom.color = "transparent",
      )
  } else {
    table <- table %>%
      gt::tab_options(
        table_body.border.bottom.color = "transparent",
      )
  }

  table
}
