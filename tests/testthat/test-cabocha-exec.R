test_that("can execute cabocha", {
  skip_if_not(is_cabocha_available())
  expect_type(ppn_cabocha(enc2utf8("\u3053\u3093\u306b\u3061\u306f")), "character")
})
