test_that("gibasa works", {
  xml <- ppn_parse_xml(system.file("sample.xml", package = "pipian", mustWork = TRUE))
  expect_type(gbs_c(xml), "list")
  expect_s3_class(gbs_freq(xml), "data.frame")
  expect_s4_class(gbs_dfm(xml), "dfm")
  expect_s4_class(gbs_collocate(xml), "fcm")
})
