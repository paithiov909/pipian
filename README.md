# pipian

[![GitHub license](https://img.shields.io/github/license/paithiov909/pipian.svg)](https://github.com/paithiov909/pipian/blob/master/LICENSE)

A tiny interface to CaboCha

## Installation

```R
remotes::install_github("paithiov909/pipian")
```

## Requirements

- MeCab (>= 0.996)
- CaboCha (>= 0.69)

## Usage

### Parsing dependency

```R
> res <- pipian::CabochaTbl("ふと振り向くと、たくさんの味方がいてたくさんの優しい人間がいることを、わざわざ自分の誕生日が来ないと気付けない自分を奮い立たせながらも、毎日こんな、湖のようななんの引っ掛かりもない、落ちつき倒し、音一つも感じさせない人間でいれる方に憧れを持てたとある25歳の眩しき朝のことでした")
> res$tbl
# A tibble: 37 x 4
   id    link  score     morphs      
   <chr> <chr> <chr>     <chr>       
 1 0     1     1.287564  ふと        
 2 1     36    -2.336376 振り向くと、
 3 2     3     1.927252  たくさんの  
 4 3     4     0.834422  味方が      
 5 4     8     2.020974  いて        
 6 5     7     1.913107  たくさんの  
 7 6     7     1.773527  優しい      
 8 7     8     2.371958  人間が      
 9 8     9     3.138138  いる        
10 9     13    0.293884  ことを、    
# ... with 27 more rows
```

### Plotting

```R
> res$plot()
```

![Rplot.png](https://qiita-image-store.s3.amazonaws.com/0/228173/60b9dc99-954e-82a0-b428-9dba6ffd0520.png)

### Getting dependency as flatXML

~~~R
> head(pipian::cabochaFlatXML("ふと振り向くと、たくさんの味方がいてたくさんの優しい人間がいることを、わざわざ自分の誕生日が来ないと気付けない自分を奮い立たせながらも、毎日こんな、湖のようななんの引っ掛かりもない、落ちつき倒し、音一つも感じさせない人間でいれる方に憧れを持てたとある25歳の眩しき朝のことでした"))
      elem. elemid. attr. value.    level1   level2 level3 level4
1 sentences       1  <NA>   <NA> sentences     <NA>   <NA>   <NA>
2  sentence       2  <NA>   <NA> sentences sentence   <NA>   <NA>
3     chunk       3  <NA>   <NA> sentences sentence  chunk   <NA>
4     chunk       3    id      0 sentences sentence  chunk   <NA>
5     chunk       3  link      1 sentences sentence  chunk   <NA>
6     chunk       3   rel      D sentences sentence  chunk   <NA>
```
~~~

### Convert flatXML into tibble compatible of CabochaR 

~~~R
> res <- pipian::cabochaFlatXML("ふと振り向くと、たくさんの味方がいてたくさんの優しい人間がいることを、わざわざ自分の誕生日が来ないと気付けない自分を奮い立たせながらも、毎日こんな、湖のようななんの引っ掛かりもない、落ちつき倒し、音一つも感じさせない人間でいれる方に憧れを持てたとある25歳の眩しき朝のことでした")
> pipian::CabochaR(res)$as.tibble()
# A tibble: 78 x 17
   chunk_id    D1    D2 rel    score  head  func tok_id POS1  POS2  POS3 
      <dbl> <dbl> <dbl> <chr>  <dbl> <dbl> <dbl>  <dbl> <chr> <chr> <chr>
 1        3     0     1 D      1.29      0     0      0 副詞  一般  *    
 2        5     1    36 D     -2.34      1     2      1 動詞  自立  *    
 3        5     1    36 D     -2.34      1     2      2 助詞  接続助詞~ *    
 4        5     1    36 D     -2.34      1     2      3 記号  読点  *    
 5        9     2     3 D      1.93      4     5      4 名詞  副詞可能~ *    
 6        9     2     3 D      1.93      4     5      5 助詞  連体化~ *    
 7       12     3     4 D      0.834     6     7      6 名詞  サ変接続~ *    
 8       12     3     4 D      0.834     6     7      7 助詞  格助詞~ 一般 
 9       15     4     8 D      2.02      8     9      8 動詞  自立  *    
10       15     4     8 D      2.02      8     9      9 助詞  接続助詞~ *    
# ... with 68 more rows, and 6 more variables: POS4 <chr>,
#   X5StageUse1 <chr>, X5StageUse2 <chr>, Original <chr>, Yomi1 <chr>,
#   Yomi2 <chr>
~~~