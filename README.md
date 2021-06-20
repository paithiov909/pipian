
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pipian <a href='https://paithiov909.github.io/pipian'><img src='https://raw.githack.com/paithiov909/pipian/master/man/figures/logo.png' align="right" height="139" /></a>

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

## Installation

``` r
remotes::install_github("paithiov909/pipian")
```

## Usage

### Parsing dependency

``` r
text <- stringi::stri_enc_toutf8("ふと振り向くと、たくさんの味方がいてたくさんの優しい人間がいることを、わざわざ自分の誕生日が来ないと気付けない自分を奮い立たせながらも、毎日こんな、湖のようななんの引っ掛かりもない、落ちつき倒し、音一つも感じさせない人間でいれる方に憧れを持てたとある25歳の眩しき朝のことでした")
res <- pipian::CabochaTbl(text, force.utf8 = TRUE)
res$tbl
#> # A tibble: 37 x 4
#>    id    link  score     morphs      
#>    <chr> <chr> <chr>     <chr>       
#>  1 0     1     1.287564  ふと        
#>  2 1     36    -2.336376 振り向くと、
#>  3 2     3     1.927252  たくさんの  
#>  4 3     4     0.834422  味方が      
#>  5 4     8     2.020974  いて        
#>  6 5     7     1.913107  たくさんの  
#>  7 6     7     1.773527  優しい      
#>  8 7     8     2.371958  人間が      
#>  9 8     9     3.138138  いる        
#> 10 9     13    0.293884  ことを、    
#> # ... with 27 more rows
```

### Plotting

``` r
res$plot()
```

![Rplot.png](https://qiita-image-store.s3.amazonaws.com/0/228173/60b9dc99-954e-82a0-b428-9dba6ffd0520.png)

### Getting dependency as flatXML

``` r
head(pipian::cabochaFlatXML(text, force.utf8 = TRUE))
#>       elem. elemid. attr. value.    level1   level2 level3 level4
#> 1 sentences       1  <NA>   <NA> sentences     <NA>   <NA>   <NA>
#> 2  sentence       2  <NA>   <NA> sentences sentence   <NA>   <NA>
#> 3     chunk       3  <NA>   <NA> sentences sentence  chunk   <NA>
#> 4     chunk       3    id      0 sentences sentence  chunk   <NA>
#> 5     chunk       3  link      1 sentences sentence  chunk   <NA>
#> 6     chunk       3   rel      D sentences sentence  chunk   <NA>
```

### Converting flatXML into tibble compatible with CabochaR

``` r
res <- pipian::cabochaFlatXML(text, force.utf8 = TRUE) %>%
  pipian::CabochaR()
```

``` r
res$morphs[[1]]
#> # A tibble: 78 x 13
#>    chunk_idx tok_idx ne_value Surface POS1  POS2  POS3  POS4  X5StageUse1
#>        <dbl>   <dbl> <chr>    <chr>   <chr> <chr> <chr> <chr> <chr>      
#>  1         3       0 O        ふと    副詞  一般  <NA>  <NA>  <NA>       
#>  2         5       1 O        振り向く~ 動詞  自立  <NA>  <NA>  五段・カ行イ音便~
#>  3         5       2 O        と      助詞  接続助詞~ <NA>  <NA>  <NA>       
#>  4         5       3 O        、      記号  読点  <NA>  <NA>  <NA>       
#>  5         9       4 O        たくさん~ 名詞  副詞可能~ <NA>  <NA>  <NA>       
#>  6         9       5 O        の      助詞  連体化~ <NA>  <NA>  <NA>       
#>  7        12       6 O        味方    名詞  サ変接続~ <NA>  <NA>  <NA>       
#>  8        12       7 O        が      助詞  格助詞~ 一般  <NA>  <NA>       
#>  9        15       8 O        い      動詞  自立  <NA>  <NA>  一段       
#> 10        15       9 O        て      助詞  接続助詞~ <NA>  <NA>  <NA>       
#> # ... with 68 more rows, and 4 more variables: X5StageUse2 <chr>,
#> #   Original <chr>, Yomi1 <chr>, Yomi2 <chr>
```

``` r
res$as_tibble()
#> # A tibble: 78 x 20
#>    sentence_idx chunk_idx D1    D2    rel   score head  func  tok_idx ne_value
#>           <int>     <dbl> <chr> <chr> <chr> <chr> <chr> <chr>   <dbl> <chr>   
#>  1            1         3 0     1     D     1.28~ 0     0           0 O       
#>  2            1         5 1     36    D     -2.3~ 1     2           1 O       
#>  3            1         5 1     36    D     -2.3~ 1     2           2 O       
#>  4            1         5 1     36    D     -2.3~ 1     2           3 O       
#>  5            1         9 2     3     D     1.92~ 4     5           4 O       
#>  6            1         9 2     3     D     1.92~ 4     5           5 O       
#>  7            1        12 3     4     D     0.83~ 6     7           6 O       
#>  8            1        12 3     4     D     0.83~ 6     7           7 O       
#>  9            1        15 4     8     D     2.02~ 8     9           8 O       
#> 10            1        15 4     8     D     2.02~ 8     9           9 O       
#> # ... with 68 more rows, and 10 more variables: Surface <chr>, POS1 <chr>,
#> #   POS2 <chr>, POS3 <chr>, POS4 <chr>, X5StageUse1 <chr>, X5StageUse2 <chr>,
#> #   Original <chr>, Yomi1 <chr>, Yomi2 <chr>
```

The output has these columns (only when using IPA dictionary).

-   sentence\_idx: 文番号
-   chunk\_idx: 文節のインデックス
-   D1: 文節番号
-   D2: 係り先の文節の文節番号
-   rel:（よくわからない値）
-   score: 係り関係のスコア
-   head: 主辞の形態素の番号
-   func: 機能語の形態素の番号
-   tok\_idx: 形態素の番号
-   ne\_value: 固有表現解析の結果の値（`-n 1`オプションを使用している）
-   Surface: 表層形
-   POS1\~POS4: 品詞, 品詞細分類1, 品詞細分類2, 品詞細分類3
-   X5StageUse1: 活用型（五段, 下二段…）
-   X5StageUse2: 活用形（連用形, 基本形…）
-   Original: 原形
-   Yomi1\~Yomi2: 読み, 発音

## Code of Conduct

Please note that the pipian project is released with a [Contributor Code
of Conduct](https://paithiov909.github.io/pipian/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

## License

MIT license.

Icons made by [catkuro](https://www.flaticon.com/authors/catkuro) from
[Flaticon](https://www.flaticon.com/).
