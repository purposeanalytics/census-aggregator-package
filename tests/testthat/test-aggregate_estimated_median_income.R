test_that("aggregate_estimated_median_income returns NA if total count is < 1000", {
  data <- tibble::tribble(
    ~highest_parent_vector, ~vector, ~label, ~value,
    "v_CA21_923", "v_CA21_923", "Household total income groups in 2020 for private households", 385,
    "v_CA21_923", "v_CA21_924", "Under $5,000", 15,
    "v_CA21_923", "v_CA21_925", "$5,000 to $9,999", 10,
    "v_CA21_923", "v_CA21_926", "$10,000 to $14,999", 10,
    "v_CA21_923", "v_CA21_927", "$15,000 to $19,999", 10,
    "v_CA21_923", "v_CA21_928", "$20,000 to $24,999", 10,
    "v_CA21_923", "v_CA21_929", "$25,000 to $29,999", 5,
    "v_CA21_923", "v_CA21_930", "$30,000 to $34,999", 10,
    "v_CA21_923", "v_CA21_931", "$35,000 to $39,999", 10,
    "v_CA21_923", "v_CA21_932", "$40,000 to $44,999", 5,
    "v_CA21_923", "v_CA21_933", "$45,000 to $49,999", 5,
    "v_CA21_923", "v_CA21_934", "$50,000 to $59,999", 10,
    "v_CA21_923", "v_CA21_935", "$60,000 to $69,999", 15,
    "v_CA21_923", "v_CA21_936", "$70,000 to $79,999", 20,
    "v_CA21_923", "v_CA21_937", "$80,000 to $89,999", 25,
    "v_CA21_923", "v_CA21_938", "$90,000 to $99,999", 15,
    "v_CA21_923", "v_CA21_940", "$100,000 to $124,999", 45,
    "v_CA21_923", "v_CA21_941", "$125,000 to $149,999", 55,
    "v_CA21_923", "v_CA21_942", "$150,000 to $199,999", 90,
    "v_CA21_923", "v_CA21_943", "$200,000 and over", 20
  )

  estimated_median <- data %>% aggregate_estimated_median_income()

  expect_true(is.na(estimated_median[["value"]]))
})

test_that("aggregate_estimated_median_income returns NA if median is in 200,000+ bucket", {
  data <- tibble::tribble(
    ~highest_parent_vector, ~vector, ~label, ~value,
    "v_CA21_923", "v_CA21_923", "Household total income groups in 2020 for private households", 1005,
    "v_CA21_923", "v_CA21_924", "Under $5,000", 15,
    "v_CA21_923", "v_CA21_925", "$5,000 to $9,999", 10,
    "v_CA21_923", "v_CA21_926", "$10,000 to $14,999", 10,
    "v_CA21_923", "v_CA21_927", "$15,000 to $19,999", 10,
    "v_CA21_923", "v_CA21_928", "$20,000 to $24,999", 10,
    "v_CA21_923", "v_CA21_929", "$25,000 to $29,999", 5,
    "v_CA21_923", "v_CA21_930", "$30,000 to $34,999", 10,
    "v_CA21_923", "v_CA21_931", "$35,000 to $39,999", 10,
    "v_CA21_923", "v_CA21_932", "$40,000 to $44,999", 5,
    "v_CA21_923", "v_CA21_933", "$45,000 to $49,999", 5,
    "v_CA21_923", "v_CA21_934", "$50,000 to $59,999", 10,
    "v_CA21_923", "v_CA21_935", "$60,000 to $69,999", 15,
    "v_CA21_923", "v_CA21_936", "$70,000 to $79,999", 20,
    "v_CA21_923", "v_CA21_937", "$80,000 to $89,999", 25,
    "v_CA21_923", "v_CA21_938", "$90,000 to $99,999", 15,
    "v_CA21_923", "v_CA21_940", "$100,000 to $124,999", 45,
    "v_CA21_923", "v_CA21_941", "$125,000 to $149,999", 55,
    "v_CA21_923", "v_CA21_942", "$150,000 to $199,999", 90,
    "v_CA21_923", "v_CA21_943", "$200,000 and over", 645
  )

  estimated_median <- data %>% aggregate_estimated_median_income()

  expect_true(is.na(estimated_median[["value"]]))
})
