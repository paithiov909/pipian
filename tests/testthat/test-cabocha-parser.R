test_that("can parse xml", {
  xml <- ppn_parse_xml(system.file("sample.xml", package = "pipian", mustWork = TRUE))
  expect_s3_class(xml, "data.frame")
  expect_s3_class(ppn_make_graph(xml[xml$doc_id == 1, ]), "igraph")
})
