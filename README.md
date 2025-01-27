
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pipian <a href='https://paithiov909.github.io/pipian/'><img src='man/figures/logo.png' align="right" height="139" /></a>

<!-- badges: start -->

[![GitHub last
commit](https://img.shields.io/github/last-commit/paithiov909/pipian)](#)
[![pipian status
badge](https://paithiov909.r-universe.dev/badges/pipian)](https://paithiov909.r-universe.dev)
[![R-CMD-check](https://github.com/paithiov909/pipian/actions/workflows/check.yml/badge.svg)](https://github.com/paithiov909/pipian/actions/workflows/check.yml)
[![Codecov test
coverage](https://codecov.io/gh/paithiov909/pipian/branch/main/graph/badge.svg)](https://app.codecov.io/gh/paithiov909/pipian?branch=main)
<!-- badges: end -->

pipian is a tiny interface to
[CaboCha](https://taku910.github.io/cabocha/); a Japanese dependency
structure parser. The main goal of pipian is to implement a parser for
that XML output.

## System Requirements

- CaboCha
- C++11

## Usage

### Installation

``` r
remotes::install_github("paithiov909/pipian")
```

### Cast dependency structure as an igraph

``` r
sentence <- "ふと振り向くと、たくさんの味方がいてたくさんの優しい人間がいることを、わざわざ自分の誕生日が来ないと気付けない自分を奮い立たせながらも、毎日こんな、湖のようななんの引っ掛かりもない、落ちつき倒し、音一つも感じさせない人間でいれる方に憧れを持てたとある25歳の眩しき朝のことでした"

df <- sentence |>
  pipian::ppn_cabocha() |>
  pipian::ppn_parse_xml()

head(df)
#> # A tibble: 6 × 19
#>   doc_id sentence_id chunk_id token_id token   chunk_link chunk_score chunk_head
#>    <int>       <int>    <int>    <int> <chr>        <int>       <dbl>      <int>
#> 1      1           1        1        0 ふと             2        1.29          1
#> 2      1           1        2        1 振り向く……         36       -1.17          2
#> 3      1           1        2        2 と              36       -1.17          2
#> 4      1           1        2        3 、              36       -1.17          2
#> 5      1           1        3        4 たくさん……          4        1.93          5
#> 6      1           1        3        5 の               4        1.93          5
#> # ℹ 11 more variables: chunk_func <int>, entity <chr>, POS1 <chr>, POS2 <chr>,
#> #   POS3 <chr>, POS4 <chr>, X5StageUse1 <chr>, X5StageUse2 <chr>,
#> #   Original <chr>, Yomi1 <chr>, Yomi2 <chr>

g <- df |>
  pipian::ppn_make_graph()

print(g)
#> IGRAPH c1835b0 DN-- 37 37 -- 
#> + attr: name (v/c), tokens (v/c), pos (v/c), score (e/n)
#> + edges from c1835b0 (vertex names):
#>  [1] 111 ->112  112 ->1136 113 ->114  114 ->115  115 ->119  116 ->118 
#>  [7] 117 ->118  118 ->119  119 ->1110 1110->1136 1111->1114 1112->1113
#> [13] 1113->1114 1114->1117 1115->1116 1116->1117 1117->1131 1118->1119
#> [19] 1119->1129 1120->1121 1121->1122 1122->1123 1123->1129 1124->1126
#> [25] 1125->1126 1126->1127 1127->1128 1128->1129 1129->1131 1130->1131
#> [31] 1131->1135 1132->1133 1133->1135 1134->1135 1135->1136 1136->110 
#> [37] 110 ->110
```

``` r
pagerank <- igraph::page_rank(g, directed = TRUE)

plot(
  g,
  vertex.size = pagerank$vector * 50,
  vertex.color = "steelblue",
  vertex.label = igraph::V(g)$tokens,
  vertex.label.cex = 0.6,
  vertex.label.color = "black",
  vertex.label.family = "sans-serif",
  edge.width = 0.4,
  edge.arrow.size = 0.4,
  edge.color = "gray80",
  layout = igraph::layout_as_tree(g, mode = "in", flip.y = FALSE),
)
```

<img src="man/figures/README-deps-1.png" width="100%" />

## License

MIT license.

Icons made by [catkuro](https://www.flaticon.com/authors/catkuro) from
[Flaticon](https://www.flaticon.com/).
