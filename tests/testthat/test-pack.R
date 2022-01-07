skip_if_not(is_cabocha_available())

test_that("pack works", {
  res1 <- ppn_parse_xml(ppn_cabocha(enc2utf8("\u3053\u3093\u306b\u3061\u306f")))
  res2 <- pack(res1)
  res3 <- pack(res1, n = 2L)
  expect_s3_class(res2, "data.frame")
  expect_s3_class(res3, "data.frame")
})
