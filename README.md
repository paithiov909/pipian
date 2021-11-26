
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pipian <a href='https://paithiov909.github.io/pipian/'><img src='man/figures/logo.png' align="right" height="139" /></a>

<!-- badges: start -->

[![GitHub last
commit](https://img.shields.io/github/last-commit/paithiov909/pipian)](#)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/paithiov909/pipian/actions/workflows/check.yml/badge.svg)](https://github.com/paithiov909/pipian/actions/workflows/check.yml)
[![Codecov test
coverage](https://codecov.io/gh/paithiov909/pipian/branch/main/graph/badge.svg)](https://app.codecov.io/gh/paithiov909/pipian?branch=main)
<!-- badges: end -->

pipian is a tiny interface to
[CaboCha](https://taku910.github.io/cabocha/); a Japanese dependency
structure parser. The main goal of pipian is to implement a parser for
that XML output.

## System Requirements

-   CaboCha
-   C++11

## Usage

### Installation

``` r
remotes::install_github("paithiov909/pipian")
```

### Cast dependency structure as an igraph

``` r
sentence <- "ふと振り向くと、たくさんの味方がいてたくさんの優しい人間がいることを、わざわざ自分の誕生日が来ないと気付けない自分を奮い立たせながらも、毎日こんな、湖のようななんの引っ掛かりもない、落ちつき倒し、音一つも感じさせない人間でいれる方に憧れを持てたとある25歳の眩しき朝のことでした"

g <- sentence %>% 
  pipian::ppn_cabocha() %>% 
  pipian::ppn_parse_xml() %>% 
  pipian::ppn_make_graph()

print(g)
#> IGRAPH 570dd7c DN-- 38 38 -- 
#> + attr: name (v/c), tokens (v/c), pos (v/c), score (e/n)
#> + edges from 570dd7c (vertex names):
#>  [1] 111 ->112  112 ->1137 113 ->114  114 ->115  115 ->119  116 ->118 
#>  [7] 117 ->118  118 ->119  119 ->1110 1110->1114 1111->1114 1112->1113
#> [13] 1113->1114 1114->1118 1115->1116 1116->1117 1117->1118 1118->1132
#> [19] 1119->1120 1120->1130 1121->1122 1122->1123 1123->1124 1124->1130
#> [25] 1125->1127 1126->1127 1127->1128 1128->1129 1129->1130 1130->1132
#> [31] 1131->1132 1132->1136 1133->1134 1134->1136 1135->1136 1136->1137
#> [37] 1137->110  110 ->110
```

``` r
pagerank <- igraph::page.rank(g, directed = TRUE)

plot(
  g,
  vertex.size = pagerank$vector * 50,
  vertex.color = "steelblue",
  vertex.label = igraph::V(g)$tokens,
  vertex.label.cex = 0.8,
  vertex.label.color = "black",
  edge.width = 0.4,
  edge.arrow.size = 0.4,
  edge.color = "gray80",
  layout = igraph::layout_as_tree(g, mode = "in", flip.y = FALSE)
)
```

<img src="man/figures/README-deps-1.png" width="100%" />

## License

MIT license.

Icons made by [catkuro](https://www.flaticon.com/authors/catkuro) from
[Flaticon](https://www.flaticon.com/).
