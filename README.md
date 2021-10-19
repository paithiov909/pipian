
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pipian <a href='https://paithiov909.github.io/pipian'><img src='man/figures/logo.png' align="right" height="139" /></a>

<!-- badges: start -->

[![GitHub last
commit](https://img.shields.io/github/last-commit/paithiov909/pipian)](#)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Codecov test
coverage](https://codecov.io/gh/paithiov909/pipian/branch/main/graph/badge.svg)](https://codecov.io/gh/paithiov909/pipian?branch=main)
<!-- badges: end -->

pipian is a tiny interface to
[CaboCha](https://taku910.github.io/cabocha/); a Japanese dependency
structure parser.

## System Requirements

-   MeCab
-   CaboCha
-   C++11

## Usage

### Installation

``` r
remotes::install_github("paithiov909/pipian")
```

### Plot dependency structure

``` r
sentence <- "ふと振り向くと、たくさんの味方がいてたくさんの優しい人間がいることを、わざわざ自分の誕生日が来ないと気付けない自分を奮い立たせながらも、毎日こんな、湖のようななんの引っ掛かりもない、落ちつき倒し、音一つも感じさせない人間でいれる方に憧れを持てたとある25歳の眩しき朝のことでした"

sentence %>% 
  pipian::ppn_cabocha() %>% 
  pipian::ppn_parse_xml() %>% 
  pipian::ppn_plot_igraph(sentence_id = 1L)
```

<img src="man/figures/README-deps-1.png" width="100%" />

### Mimics of RMeCab functions (experimental)

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

### Cast CaboCha output XML as data.table

``` r
sentence %>% 
  pipian::ppn_cabocha() %>% 
  pipian::ppn_parse_xml() %>% 
  pipian::ppn_as_tokenindex() %>% 
  head()
#>    doc_id sentence token_id    token chunk_score POS1     POS2 POS3 POS4
#> 1:      1        1     1100      EOS          NA ROOT     <NA> <NA> <NA>
#> 2:      1        1     1110     ふと    1.287564 副詞     一般 <NA> <NA>
#> 3:      1        1     1121 振り向く   -2.336376 動詞     自立 <NA> <NA>
#> 4:      1        1     1122       と   -2.336376 助詞 接続助詞 <NA> <NA>
#> 5:      1        1     1123       、   -2.336376 記号     読点 <NA> <NA>
#> 6:      1        1     1134 たくさん    1.927252 名詞 副詞可能 <NA> <NA>
#>         X5StageUse1 X5StageUse2 Original    Yomi1    Yomi2 entity relation
#> 1:             <NA>        <NA>     <NA>     <NA>     <NA>   <NA>     ROOT
#> 2:             <NA>        <NA>     ふと     フト     フト   <NA>     ROOT
#> 3: 五段・カ行イ音便      基本形 振り向く フリムク フリムク   <NA>     動詞
#> 4:             <NA>        <NA>       と       ト       ト   <NA>     ROOT
#> 5:             <NA>        <NA>       、       、       、   <NA>     記号
#> 6:             <NA>        <NA> たくさん タクサン タクサン   <NA>     名詞
#>    parent
#> 1:     NA
#> 2:     NA
#> 3:   1122
#> 4:     NA
#> 5:   1122
#> 6:   1135
```

## License

MIT license.

Icons made by [catkuro](https://www.flaticon.com/authors/catkuro) from
[Flaticon](https://www.flaticon.com/).
