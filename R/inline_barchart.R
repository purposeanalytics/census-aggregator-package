#' @export
inline_barchart <- function(data) {
  data %>%
    dplyr::mutate(
      hist = value_proportion,
      value_proportion = scales::percent(value_proportion, accuracy = 0.1)
    ) %>%
    dplyr::select(label, hist, value_proportion) %>%
    gt::gt() %>%
    gtExtras::gt_plt_bar_pct(hist, scaled = FALSE, fill = "grey", background = "transparent") %>%
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
