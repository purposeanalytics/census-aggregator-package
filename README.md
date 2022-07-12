
<!-- README.md is generated from README.Rmd. Please edit that file -->

# censusaggregate

The goal of censusaggregate is to easily retrieve and aggregate Canadian
census vectors, and their breakdowns, across multiple (shared)
geographies.

## Installation

You can install censusaggregate from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("purposeanalytics/census-aggregator-package")
```

## API key and cacheing

TODO

## Usage

``` r
library(cancensus)
library(censusaggregate)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

dataset <- "CA16"

vector <- list_census_vectors(dataset) %>%
  filter(label == "Occupied private dwellings by structural type of dwelling data")

vector
#> # A tibble: 1 × 7
#>   vector     type  label         units parent_vector aggregation details        
#>   <chr>      <fct> <chr>         <fct> <chr>         <chr>       <chr>          
#> 1 v_CA16_408 Total Occupied pri… Numb… <NA>          Additive    CA 2016 Census…

vector <- vector[["vector"]]

vector_with_breakdowns <- get_census_vectors_and_children(
  dataset,
  regions = list(CSD = c("3520005", "3521005", "3521010")),
  level = "CSD",
  vectors = vector
)

vector_with_breakdowns %>%
  glimpse()
#> Rows: 30
#> Columns: 13
#> $ highest_parent_vector <chr> "v_CA16_408", "v_CA16_408", "v_CA16_408", "v_CA1…
#> $ vector                <chr> "v_CA16_408", "v_CA16_408", "v_CA16_408", "v_CA1…
#> $ type                  <fct> Total, Total, Total, Total, Total, Total, Total,…
#> $ label                 <chr> "Occupied private dwellings by structural type o…
#> $ units                 <fct> Number, Number, Number, Number, Number, Number, …
#> $ parent_vector         <chr> NA, NA, NA, "v_CA16_408", "v_CA16_408", "v_CA16_…
#> $ aggregation           <chr> "Additive", "Additive", "Additive", "Additive", …
#> $ aggregation_type      <chr> "Additive", "Additive", "Additive", "Additive", …
#> $ details               <chr> "CA 2016 Census; 100% data; Occupied private dwe…
#> $ geo_uid               <chr> "3520005", "3521005", "3521010", "3520005", "352…
#> $ population            <dbl> 2731571, 721599, 593638, 2731571, 721599, 593638…
#> $ households            <dbl> 1112929, 240913, 168011, 1112929, 240913, 168011…
#> $ value                 <dbl> 1112930, 240915, 168015, 269675, 90780, 87550, 4…

vector_with_breakdowns %>%
  aggregate_census_vectors() %>%
  glimpse()
#> Rows: 10
#> Columns: 11
#> $ highest_parent_vector <chr> "v_CA16_408", "v_CA16_408", "v_CA16_408", "v_CA1…
#> $ vector                <chr> "v_CA16_408", "v_CA16_409", "v_CA16_410", "v_CA1…
#> $ type                  <fct> Total, Total, Total, Total, Total, Total, Total,…
#> $ label                 <chr> "Occupied private dwellings by structural type o…
#> $ units                 <fct> Number, Number, Number, Number, Number, Number, …
#> $ parent_vector         <chr> NA, "v_CA16_408", "v_CA16_408", "v_CA16_408", "v…
#> $ aggregation           <chr> "Additive", "Additive", "Additive", "Additive", …
#> $ aggregation_type      <chr> "Additive", "Additive", "Additive", "Additive", …
#> $ details               <chr> "CA 2016 Census; 100% data; Occupied private dwe…
#> $ value                 <dbl> 1521860, 448005, 573935, 499455, 120985, 116410,…
#> $ value_proportion      <dbl> 1.0000000000, 0.2943799035, 0.3771273310, 0.3281…
```

## Related work

censusaggregate heavily relies on existing work from [`cancensus`]()
(and the related [CensusMapper]()) to fetch census data. It has some
similar functionality to the [`tongfen`]() package, but is not as
feature rich - rather, it focuses on exclusively getting and aggregating
Canadian census vectors across multiple (shared) geographies (in
contrast to `tongfen`, which …)
