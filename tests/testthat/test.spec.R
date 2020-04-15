#### Test ####

intern <- "cabocha of 0.69"
sentence <-
  enc2native(
    "\u3075\u3068\u632F\u308A\u5411\u304F\u3068\u3001\u305F\u304F\u3055\u3093\u306E\u5473\u65B9\u304C\u3044\u3066\u305F\u304F\u3055\u3093\u306E\u512A\u3057\u3044\u4EBA\u9593\u304C\u3044\u308B\u3053\u3068\u3092\u3001\u308F\u3056\u308F\u3056\u81EA\u5206\u306E\u8A95\u751F\u65E5\u304C\u6765\u306A\u3044\u3068\u6C17\u4ED8\u3051\u306A\u3044\u81EA\u5206\u3092\u596E\u3044\u7ACB\u305F\u305B\u306A\u304C\u3089\u3082\u3001\u6BCE\u65E5\u3053\u3093\u306A\u3001\u6E56\u306E\u3088\u3046\u306A\u306A\u3093\u306E\u5F15\u3063\u639B\u304B\u308A\u3082\u306A\u3044\u3001\u843D\u3061\u3064\u304D\u5012\u3057\u3001\u97F3\u4E00\u3064\u3082\u611F\u3058\u3055\u305B\u306A\u3044\u4EBA\u9593\u3067\u3044\u308C\u308B\u65B9\u306B\u61A7\u308C\u3092\u6301\u3066\u305F\u3068\u3042\u308B25\u6B73\u306E\u7729\u3057\u304D\u671D\u306E\u3053\u3068\u3067\u3057\u305F"
  )

#### Specs ####


describe("Output Verification", {
  describe("Check cabocha is available", {
    it("Available?", {
      version <- try(system("cabocha --version", intern = TRUE))
      expect_equivalent(version, intern)
    })
  })

  describe("CabochaTbl()?", {
    res1 <- pipian::CabochaTbl(sentence)

    it("res$tbl?", {
      expect_equivalent(
        res1$tbl$morphs[2],
        enc2utf8("\u632F\u308A\u5411\u304F\u3068\u3001")
      )
    })
    it("res$tbl2graph()?", {
      expect_type(res1$tbl2graph(), "list")
    })
  })


  describe("CabochaR()?", {
    res2 <- pipian::cabochaFlatXML(sentence)

    it("cabochaFlatXML()?", {
      expect_type(res2, "list")
    })

    describe("CabochaR()", {
      res3 <- pipian::CabochaR(res2)

      it("res$attributes?", {
        expect_type(res3$attributes, "list")
      })
      it("res$morphs?", {
        expect_type(res3$morphs, "list")
      })
      it("res$as.tibble()?", {
        expect_equivalent(res3$as.tibble()$chunk_id[1], 3)
        expect_equivalent(
          res3$as.tibble()$word[5],
          enc2utf8("\u305F\u304F\u3055\u3093")
        )
      })
    })
  })
})
