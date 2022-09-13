library(cancensus)

census_vectors <- list_census_vectors("CA16")

usethis::use_data(census_vectors, overwrite = TRUE)
