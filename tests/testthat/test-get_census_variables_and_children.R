CA16_census_vectors <- readRDS(system.file("testdata/CA16_census_vectors.rds", package = "censusaggregate"))

test_that("census_vector_is_parent returns TRUE if the vector is a parent to any other vectors", {
  skip_if_offline()
  skip_on_ci()
  skip_on_cran()

  expect_true(
    census_vector_is_parent(CA16_census_vectors, "v_CA16_404")
  )

  expect_true(
    census_vector_is_parent(CA16_census_vectors, "v_CA16_4047")
  )
})

test_that("census_vector_is_parent returns FALSE if the vector is NOT a parent to any other vectors", {
  skip_if_offline()
  skip_on_ci()
  skip_on_cran()

  expect_false(
    census_vector_is_parent(CA16_census_vectors, "v_CA16_401")
  )
})
