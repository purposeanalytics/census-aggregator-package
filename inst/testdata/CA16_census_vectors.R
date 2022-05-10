library(cancensus)

vectors <- list_census_vectors("CA16")

saveRDS(vectors, here::here("inst", "testdata", "CA16_census_vectors.rds"))
