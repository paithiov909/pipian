# pipian

[![GitHub issues](https://img.shields.io/github/issues/paithiov909/pipian.svg)](https://github.com/paithiov909/pipian/issues) [![GitHub license](https://img.shields.io/github/license/paithiov909/pipian.svg)](https://github.com/paithiov909/pipian/blob/master/LICENSE)

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
# A tibble: 6 x 8
  elem.     elemid. attr. value. level1    level2   level3 level4
  <chr>       <dbl> <chr> <chr>  <chr>     <chr>    <chr>  <chr> 
1 sentences       1 NA    NA     sentences NA       NA     NA    
2 sentence        2 NA    NA     sentences sentence NA     NA    
3 chunk           3 NA    NA     sentences sentence chunk  NA    
4 chunk           3 id    0      sentences sentence chunk  NA    
5 chunk           3 link  1      sentences sentence chunk  NA    
6 chunk           3 rel   D      sentences sentence chunk  NA   
```
~~~

