check_internet <- function() {
  if (!curl::has_internet()) {
    stop("This package does not work offline. Please check your internet connection.",
         call. = FALSE
    )
  }
}
