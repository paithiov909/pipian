skip_if_not(is_cabocha_available())

test_that("can execute cabocha", {
  expect_type(ppn_cabocha(enc2utf8("\u3053\u3093\u306b\u3061\u306f")), "character")
})
