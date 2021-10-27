
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
#> IGRAPH fe3809f DN-- 38 38 -- 
#> + attr: name (v/c), tokens (v/c), pos (v/c), score (e/n)
#> + edges from fe3809f (vertex names):
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

### Mimics of RMeCab functions

#### Alternative of RMeCabC

``` r
sentence %>% 
  pipian::ppn_cabocha() %>% 
  pipian::ppn_parse_xml() %>% 
  pipian::gbs_c()
#> [[1]]
#>         副詞         動詞         助詞         記号         名詞         助詞 
#>       "ふと"   "振り向く"         "と"         "、"   "たくさん"         "の" 
#>         名詞         助詞         動詞         助詞         名詞         助詞 
#>       "味方"         "が"         "い"         "て"   "たくさん"         "の" 
#>       形容詞         名詞         助詞         動詞         名詞         助詞 
#>     "優しい"       "人間"         "が"       "いる"       "こと"         "を" 
#>         記号         副詞         名詞         助詞         名詞         名詞 
#>         "、"   "わざわざ"       "自分"         "の"       "誕生"         "日" 
#>         助詞         動詞       助動詞         助詞         名詞       形容詞 
#>         "が"         "来"       "ない"         "と"     "気付け"       "ない" 
#>         名詞         助詞         動詞         動詞         助詞         助詞 
#>       "自分"         "を"   "奮い立た"         "せ"     "ながら"         "も" 
#>         記号         名詞       連体詞         記号         名詞         助詞 
#>         "、"       "毎日"     "こんな"         "、"         "湖"         "の" 
#>         名詞       助動詞         名詞         助詞         名詞         助詞 
#>       "よう"         "な"       "なん"         "の" "引っ掛かり"         "も" 
#>       形容詞         記号         名詞         動詞         記号         名詞 
#>       "ない"         "、"   "落ちつき"       "倒し"         "、"         "音" 
#>         名詞         助詞         動詞         動詞       助動詞         名詞 
#>       "一つ"         "も"       "感じ"       "させ"       "ない"       "人間" 
#>         助詞         動詞         名詞         助詞         動詞         助詞 
#>         "で"     "いれる"         "方"         "に"       "憧れ"         "を" 
#>         動詞       助動詞       連体詞         名詞         名詞         助詞 
#>       "持て"         "た"     "とある"         "25"         "歳"         "の" 
#>       形容詞         名詞         助詞         名詞       助動詞       助動詞 
#>     "眩しき"         "朝"         "の"       "こと"       "でし"         "た" 
#>         ROOT 
#>        "EOS"
```

#### Alternative of RMeCabFreq

``` r
sentence %>% 
  pipian::ppn_cabocha() %>% 
  pipian::ppn_parse_xml() %>% 
  pipian::gbs_freq()
#> # A tibble: 53 x 4
#>    Term   Info1  Info2   Freq
#>    <chr>  <chr>  <chr>  <int>
#>  1 、     記号   読点       6
#>  2 25     名詞   数         1
#>  3 い     動詞   自立       1
#>  4 いる   動詞   自立       1
#>  5 いれる 動詞   自立       1
#>  6 が     助詞   格助詞     3
#>  7 こと   名詞   非自立     2
#>  8 こんな 連体詞 <NA>       1
#>  9 させ   動詞   接尾       1
#> 10 せ     動詞   接尾       1
#> # ... with 43 more rows
```

#### Alternative of docDF family

``` r
sentence %>% 
  pipian::ppn_cabocha() %>% 
  pipian::ppn_parse_xml() %>% 
  pipian::gbs_dfm()
#> Document-feature matrix of: 1 document, 52 features (0.00% sparse) and 0 docvars.
#>     features
#> docs ふと 振り向く と 、 たくさん の 味方 が い て
#>    1    1        1  2  6        2  7    1  3  1  1
#> [ reached max_nfeat ... 42 more features ]
```

#### Alternative of collocate family

``` r
sentence %>% 
  pipian::ppn_cabocha() %>% 
  pipian::ppn_parse_xml() %>% 
  pipian::gbs_collocate()
#> Feature co-occurrence matrix of: 52 by 52 features.
#>           features
#> features   ふと 振り向く と 、 たくさん の 味方 が い て
#>   ふと        0        1  2  6        2  7    1  3  1  1
#>   振り向く    0        0  2  6        2  7    1  3  1  1
#>   と          0        0  1 12        4 14    2  6  2  2
#>   、          0        0  0 15       12 42    6 18  6  6
#>   たくさん    0        0  0  0        1 14    2  6  2  2
#>   の          0        0  0  0        0 21    7 21  7  7
#>   味方        0        0  0  0        0  0    0  3  1  1
#>   が          0        0  0  0        0  0    0  3  3  3
#>   い          0        0  0  0        0  0    0  0  0  1
#>   て          0        0  0  0        0  0    0  0  0  0
#> [ reached max_feat ... 42 more features, reached max_nfeat ... 42 more features ]
```

## License

MIT license.

Icons made by [catkuro](https://www.flaticon.com/authors/catkuro) from
[Flaticon](https://www.flaticon.com/).
