#' Get census variables and children
#'
#' Get data for census variables and all of their children (and their childrens' children, etc).
#'
#' @param dataset The dataset to query variables from. Defaults to "CA16", the 2016 Canadian Census.
#' @param region A named list of census regions to retrieve, e.g. ... TODO - do we want to offer all the same options as cancensus? Probably yes!
#' @param level The census aggregation level to retrieve, defaults to ... TODO - do we want to offer all the same options as cancensus? Probably yes!
#' @param variables An R vector containing the variable short codes for the Census variables to download. Variable short codes can be found via \link[cancensus]{list_census_vectors}.
#'
#' @return
#' @export
#'
#' @examples
#'
#' get_census_variable_and_children()
get_census_variables_and_children <- function(dataset = "CA16", regions, level, variables) {

}
