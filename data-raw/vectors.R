library(cancensus)

vectors <- list_census_vectors("CA16")

usethis::use_data(vectors, overwrite = TRUE)
