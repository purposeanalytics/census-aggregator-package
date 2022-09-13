#' Plot a neighbourhood profile variable
#'
#' @param data Census data, aggregated via \code{\link{aggregate_census_vectors}}
#' @param prop Whether the vector to be displayed is a proportion. Defaults to TRUE.
#' @param width Passed along to str_wrap for wrapping y-axis labels. Defaults to a width of 20.
#' @param dollar Whether the variable shown is in dollars. Defaults to FALSE.
#'
#' @export
#'
#' @examples
#' # TODO
plot_census_vector_static <- function(data, prop = TRUE, width = 20, dollar = FALSE) {

  # Select value_proportion if prop = TRUE

  if (prop) {
    data <- data %>%
      dplyr::select(-.data$value) %>%
      dplyr::rename(value = .data$value_proportion)
  }

  # Format value variable

  if (dollar) {
    data <- data %>%
      dplyr::mutate(value_label = scales::dollar(.data$value))
  } else {
    data <- data %>%
      dplyr::mutate(value_label = scales::percent(.data$value, accuracy = 0.1))
  }

  # Reverse label ordering so plots read from top to bottom

  data <- data %>%
    dplyr::mutate(label = forcats::fct_rev(.data$label))

  # Linewrap long labels

  data <- data %>%
    dplyr::mutate(label = str_wrap_factor(.data$label, width = width))

  # browser()

  # Initial plot

  p <- ggplot2::ggplot(data = data) +
    ggplot2::geom_col(ggplot2::aes(x = value, y = label)) +
    ggplot2::geom_text(ggplot2::aes(x = value, y = label, label = value_label), hjust = -0.25)

  # Format x-axis labels (% or $)

  if (dollar) {
    p <- p + ggplot2::scale_x_continuous(labels = scales::dollar)
  } else {
    p <- p + ggplot2::scale_x_continuous(labels = scales::percent)
  }

  # Final styling
  p +
    ggplot2::labs(x = NULL, y = NULL) +
    lemr::theme_lemr()
}

#' Plot a neighbourhood profile variable, for web
#'
#' @param data Census data, aggregated via \code{\link{aggregate_census_vectors}}
#' @param prop Whether the vector to be displayed is a proportion. Defaults to TRUE.
#' @param width Passed along to str_wrap for wrapping y-axis labels. Defaults to a width of 20.
#' @param dollar Whether the variable shown is in dollars. Defaults to FALSE.
#' @param vector_description A short description of the vector, used for forming alt text for the plot.
#' @param aria_label Aria label / alt text for the plot. Defaults to use \code{vector_description}: "Bar chart showing the breakdown of \code{vector_description}. The data is in the table that follows.", but can be overridden.
#'
#' @export
#'
#' @examples
#' # TODO
plot_census_vector <- function(data, prop = TRUE, width = 20, dollar = FALSE,
                               vector_description,
                               aria_label = glue::glue("Bar chart showing the breakdown of {vector_description}. The data is in the table that follows.")) {

  # Select value_proportion if prop = TRUE

  if (prop) {
    data <- data %>%
      dplyr::select(-.data$value) %>%
      dplyr::rename(value = .data$value_proportion)
  }

  # Format value variable

  if (dollar) {
    data <- data %>%
      dplyr::mutate(value_label = scales::dollar(.data$value))
  } else {
    data <- data %>%
      dplyr::mutate(value_label = scales::percent(.data$value, accuracy = 0.1))
  }

  # Reverse label ordering so plots read from top to bottom

  data <- data %>%
    dplyr::mutate(label = forcats::fct_rev(.data$label))

  # Linewrap long labels

  data <- data %>%
    dplyr::mutate(label = str_wrap_factor(.data$label, width = width))

  # Initial plot

  p <- plotly::plot_ly(data,
    x = ~value, y = ~label,
    type = "bar",
    color = I(grey_colour),
    hoverinfo = "skip",
    text = ~value_label,
    textposition = "outside",
    cliponaxis = FALSE,
    textfont = list(color = "black")
  )

  # Format x-axis labels (% or $)

  if (dollar) {
    p <- p %>% plotly::layout(xaxis = list(tickprefix = "$"))
  } else {
    p <- p %>% plotly::layout(xaxis = list(tickformat = "%"))
  }

  # Final styling
  p <- p %>%
    plotly::layout(
      yaxis = list(title = NA, showgrid = FALSE, fixedrange = TRUE),
      xaxis = list(title = NA, fixedrange = TRUE, showgrid = FALSE, zeroline = FALSE, showline = FALSE, showticklabels = FALSE),
      bargroupgap = 0.1,
      margin = list(t = 15, r = 25, b = 5, l = 25, pad = 6),
      showlegend = FALSE,
      font = list(family = "Lato", size = 12, color = "black")
    ) %>%
    plotly::config(displayModeBar = FALSE)

  htmltools::div(
    role = "img",
    `aria-label` = aria_label,
    p
  )
}

str_wrap_factor <- function(x, width) {
  if (!is.factor(x)) {
    x <- as.factor(x)
  }

  levels(x) <- stringr::str_wrap(levels(x), width = width)
  x
}

grey_colour <- "#B8B8B8"
base_size <- 14
