
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

## API key and caching

censusaggregate uses the
[`cancensus`](https://github.com/mountainMath/cancensus) package and
[CensusMapper API](https://censusmapper.ca/). As per their
documentation:

<blockquote>

You can obtain a free API key by [signing
up](https://censusmapper.ca/users/sign_up) for a CensusMapper account.
To check your API key, just go to “Edit Profile” (in the top-right of
the CensusMapper menu bar). Once you have your key, you can store it in
your system environment so it is automatically used in API calls. To do
so just enter cancensus::set\_api\_key(&lt;your\_api\_key&gt;, install =
TRUE).

CensusMapper API keys are free and public API quotas are generous;
however, due to incremental costs of serving large quantities of data,
there are some limits to API usage in place. For most use cases, these
API limits should not be an issue. Production uses with large extracts
of detailed geographies may run into API quota limits.

</blockquote>

In addition, censusaggregate uses `cancensus`’ caching infrastructure to
avoid repeat calls to the API:

<blockquote>

By default, cancensus caches in R’s temporary directory, but this cache
is not persistent across sessions. In order to speed up performance,
reduce quota usage, and reduce the need for unnecessary network calls,
we recommend assigning a persistent local cache using
cancensus::set\_cache\_path(<local cache path>, install = TRUE), this
enables more efficient loading and reuse of downloaded data. Users will
be prompted with a suggestion to change their default cache location
when making API calls if one has not been set yet.

</blockquote>

## Usage

censusaggregate has two primary functions, the first of which is to
retrieve a census vector and *all* of its child vectors (children).
Child vectors further break down or provide additional detail to a
vector. For example, if we want to get the vector that describes the
structural type of dwellings, first we list all vectors for the 2016
census, then filter for the one of interest:

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
```

Next we can retrieve the vector using its code (v\_CA16\_408) and its
children, for a given set of regions and at a given level. Here, we
retrieve data for three Census subdivisions (CSD), then look at the
data, which includes information like the highest parent vector, a
description of the vector, the units its in, its direct parent (since
children can be nested), the geographic identifier of the CSD, the
population and number of households in that CSD, and the data value
itself.

``` r
vector <- vector[["vector"]]

csd_regions <- list(CSD = c("3520005", "3521005", "3521010"))

vector_with_breakdowns <- get_census_vectors_and_children(
  dataset,
  regions = csd_regions,
  level = "CSD",
  vectors = vector
)

vector_with_breakdowns
#> # A tibble: 30 × 13
#>    highest_parent_vector vector     type  label  units parent_vector aggregation
#>    <chr>                 <chr>      <fct> <chr>  <fct> <chr>         <chr>      
#>  1 v_CA16_408            v_CA16_408 Total Occup… Numb… <NA>          Additive   
#>  2 v_CA16_408            v_CA16_408 Total Occup… Numb… <NA>          Additive   
#>  3 v_CA16_408            v_CA16_408 Total Occup… Numb… <NA>          Additive   
#>  4 v_CA16_408            v_CA16_409 Total Singl… Numb… v_CA16_408    Additive   
#>  5 v_CA16_408            v_CA16_409 Total Singl… Numb… v_CA16_408    Additive   
#>  6 v_CA16_408            v_CA16_409 Total Singl… Numb… v_CA16_408    Additive   
#>  7 v_CA16_408            v_CA16_410 Total Apart… Numb… v_CA16_408    Additive   
#>  8 v_CA16_408            v_CA16_410 Total Apart… Numb… v_CA16_408    Additive   
#>  9 v_CA16_408            v_CA16_410 Total Apart… Numb… v_CA16_408    Additive   
#> 10 v_CA16_408            v_CA16_411 Total Other… Numb… v_CA16_408    Additive   
#> # … with 20 more rows, and 6 more variables: aggregation_type <chr>,
#> #   details <chr>, geo_uid <chr>, population <dbl>, households <dbl>,
#> #   value <dbl>
```

We can see that there are 10 vectors returned - 9 breakdowns and the
original parent vector - each of which with 3 records, one for each of
the CSDs we requested data for.

``` r
vector_with_breakdowns %>%
  count(vector, parent_vector, label)
#> # A tibble: 10 × 4
#>    vector     parent_vector label                                              n
#>    <chr>      <chr>         <chr>                                          <int>
#>  1 v_CA16_408 <NA>          Occupied private dwellings by structural type…     3
#>  2 v_CA16_409 v_CA16_408    Single-detached house                              3
#>  3 v_CA16_410 v_CA16_408    Apartment in a building that has five or more…     3
#>  4 v_CA16_411 v_CA16_408    Other attached dwelling                            3
#>  5 v_CA16_412 v_CA16_411    Semi-detached house                                3
#>  6 v_CA16_413 v_CA16_411    Row house                                          3
#>  7 v_CA16_414 v_CA16_411    Apartment or flat in a duplex                      3
#>  8 v_CA16_415 v_CA16_411    Apartment in a building that has fewer than f…     3
#>  9 v_CA16_416 v_CA16_411    Other single-attached house                        3
#> 10 v_CA16_417 v_CA16_408    Movable dwelling                                   3
```

And we can quickly look at the values themselves:

``` r
vector_with_breakdowns %>%
  select(vector, label, geo_uid, value)
#> # A tibble: 30 × 4
#>    vector     label                                               geo_uid  value
#>    <chr>      <chr>                                               <chr>    <dbl>
#>  1 v_CA16_408 Occupied private dwellings by structural type of d… 3520005 1.11e6
#>  2 v_CA16_408 Occupied private dwellings by structural type of d… 3521005 2.41e5
#>  3 v_CA16_408 Occupied private dwellings by structural type of d… 3521010 1.68e5
#>  4 v_CA16_409 Single-detached house                               3520005 2.70e5
#>  5 v_CA16_409 Single-detached house                               3521005 9.08e4
#>  6 v_CA16_409 Single-detached house                               3521010 8.76e4
#>  7 v_CA16_410 Apartment in a building that has five or more stor… 3520005 4.93e5
#>  8 v_CA16_410 Apartment in a building that has five or more stor… 3521005 6.31e4
#>  9 v_CA16_410 Apartment in a building that has five or more stor… 3521010 1.75e4
#> 10 v_CA16_411 Other attached dwelling                             3520005 3.50e5
#> # … with 20 more rows
```

The second function of censusaggregate is to aggregate the census
vectors across multiple geographies. In this case, we want to aggregate
each variable so that there is only one record for each, combining the
values across the three CSDs. To do this, we use
`aggregate_census_vectors`:

``` r
vector_with_breakdowns %>%
  aggregate_census_vectors() %>%
  select(vector, label, value, value_proportion)
#> # A tibble: 10 × 4
#>    vector     label                                       value value_proportion
#>    <chr>      <chr>                                       <dbl>            <dbl>
#>  1 v_CA16_408 Occupied private dwellings by structural … 1.52e6         1       
#>  2 v_CA16_409 Single-detached house                      4.48e5         0.294   
#>  3 v_CA16_410 Apartment in a building that has five or … 5.74e5         0.377   
#>  4 v_CA16_411 Other attached dwelling                    4.99e5         0.328   
#>  5 v_CA16_412 Semi-detached house                        1.21e5         0.0795  
#>  6 v_CA16_413 Row house                                  1.16e5         0.0765  
#>  7 v_CA16_414 Apartment or flat in a duplex              6.79e4         0.0446  
#>  8 v_CA16_415 Apartment in a building that has fewer th… 1.91e5         0.126   
#>  9 v_CA16_416 Other single-attached house                2.96e3         0.00195 
#> 10 v_CA16_417 Movable dwelling                           4.55e2         0.000299
```

In this case, it returns a field `value` which is the sum of the values
within the three CSDs, and `value_proportion`, which breaks down the
value of the highest parent vector (v\_CA16\_408). For example, there
are 448,000 households in total a Single-detached house in the queried
CSDs, which represents 29.4% of all households in those CSDs.

## Supported vector aggregation

The vector aggregation happens automatically, based on the vectors’
units and aggregation type:

``` r
vectors <- list_census_vectors("CA16") %>%
  derive_aggregation_type()

vectors  %>%
  count(units, aggregation_type)
#> # A tibble: 6 × 3
#>   units              aggregation_type     n
#>   <fct>              <chr>            <int>
#> 1 Number             Additive          6448
#> 2 Number             Average              1
#> 3 Currency           Average             41
#> 4 Currency           Median              41
#> 5 Ratio              Average             13
#> 6 Percentage (0-100) Average             79
```

In the previous example, we worked with vectors with `units = "Number"`
and `aggregation_type = "Additive"`, which is one of the three supported
aggregations:

1.  Units: Number, Aggregation Type: Additive
2.  Units: Percentage (0-100), Aggregation Type: Average
3.  Units: Currency, Aggregation Type: Average

### Units: Number, Aggregation Type: Additive

The `value` is derived by summing all of the `value` for each vector,
across geographies. The result is a count (e.g. population, households).
An additional field, `value_proportion`, is derived, describing what
proportion of the total count (e.g. of population, households) from the
highest parent vector falls within each child vector.

### Units: Percentage (0-100), Aggregation Type: Average

### Units: Currency, Aggregation Type: Average

### Special cases

There are two vectors, Population Change and Population Density, that
require use of special functions instead of the automatic
`aggregate_census_vectors`.

#### aggregate\_population\_change()

To aggregate population change across geographies,
`aggregate_population_change` is used on data that contains two
population vectors:

``` r
population_vectors <- vectors %>% 
  filter(label %in% c("Population, 2016", "Population, 2011")) %>%
  pull(vector)

population_change_data <- get_census_vectors_and_children(
  dataset = dataset,
  regions = csd_regions,
  level = "CSD",
  vectors = population_vectors
)

population_change_data %>%
  select(vector, label, geo_uid, value)
#> # A tibble: 6 × 4
#>   vector     label            geo_uid   value
#>   <chr>      <chr>            <chr>     <dbl>
#> 1 v_CA16_401 Population, 2016 3520005 2731571
#> 2 v_CA16_401 Population, 2016 3521005  721599
#> 3 v_CA16_401 Population, 2016 3521010  593638
#> 4 v_CA16_402 Population, 2011 3520005 2615060
#> 5 v_CA16_402 Population, 2011 3521005  713443
#> 6 v_CA16_402 Population, 2011 3521010  523906

population_change_data %>%
  aggregate_population_change()
#> # A tibble: 1 × 7
#>   type  label       units aggregation aggregation_type details             value
#>   <fct> <chr>       <fct> <chr>       <chr>            <chr>               <dbl>
#> 1 Total Population… Numb… Additive    Additive         CA 2016 Census; P… 0.0505
```

#### aggregate\_population\_density()

Similarly, the aggregate population density across geographies,
`aggregate_population_density` is used, passing data that contains a
population vector and the Land area in square kilometres vector:

``` r
population_density_vectors <- vectors %>%
  filter(label %in% c("Population, 2016", "Land area in square kilometres")) %>%
  pull(vector)

population_density_data <- get_census_vectors_and_children(
  dataset = dataset,
  regions = csd_regions,
  level = "CSD",
  vectors = population_density_vectors
)

population_density_data %>%
  select(vector, label, geo_uid, value)
#> # A tibble: 6 × 4
#>   vector     label                          geo_uid    value
#>   <chr>      <chr>                          <chr>      <dbl>
#> 1 v_CA16_401 Population, 2016               3520005 2731571 
#> 2 v_CA16_401 Population, 2016               3521005  721599 
#> 3 v_CA16_401 Population, 2016               3521010  593638 
#> 4 v_CA16_407 Land area in square kilometres 3520005     630.
#> 5 v_CA16_407 Land area in square kilometres 3521005     292.
#> 6 v_CA16_407 Land area in square kilometres 3521010     266.

population_density_data %>%
  aggregate_population_density()
#> # A tibble: 1 × 7
#>   type  label       units aggregation aggregation_type details             value
#>   <fct> <chr>       <fct> <chr>       <chr>            <chr>               <dbl>
#> 1 Total Population… Numb… Additive    Additive         CA 2016 Census; Po… 3404.
```

### Unsupported aggregations

The following are not supported:

1.  Units: Number, Aggregation Type: Average
2.  Units: Currency, Aggregation Type: Median
3.  Units: Ratio, Aggregation Type: Average

If you try to aggregate this data, a message and empty tibble will be
returned:

``` r
median_vector <- vectors %>%
  filter(units == "Currency", aggregation_type == "Median") %>%
  slice(1) %>%
  pull(vector)

get_census_vectors_and_children(
  dataset,
  regions = list(CSD = c("3520005", "3521005", "3521010")),
  level = "CSD",
  vectors = median_vector
) %>%
  aggregate_census_vectors()
#> Warning: Aggregation for vectors with `units: Currency` and `aggregation_type:
#> Median` is not available. Vectors with this combination have been dropped:
#> v_CA16_2207.
#> # A tibble: 0 × 0
```

## Related work

censusaggregate heavily relies on existing work from [`cancensus`]()
(and the related [CensusMapper]()) to fetch census data. It has some
similar functionality to the [`tongfen`]() package, but is not as
feature rich - rather, it focuses on exclusively getting and aggregating
Canadian census vectors across multiple (shared) geographies (in
contrast to `tongfen`, which …)
