# pipianの紹介: RからCaboChaを呼ぶだけのパッケージ書いた

## これは何？

[paithiov909/pipian](https://github.com/paithiov909/pipian)は、日本語係り受け解析器の[CaboCha](https://taku910.github.io/cabocha/)を利用するためのRパッケージです。

内部的には、`cabocha -f3 -n1`コマンドを呼んで出力した一時ファイル（XML）を読み込み、Rcpp側でデータフレームにパースしています。

## モチベーション

- [RCaBoCha](http://rmecab.jp/wiki/index.php?RCaBoCha)や[CabochaR](https://minowalab.org/cabochar/)の（特にWindows環境向けの）代替として
  - Rcppの内部でCaboChaのC/C++ APIを利用しようとすると、本来は、Windows環境では64bit向けにビルドされたCaboChaバイナリが必要になります。しかし、CaboCha本体の64bit対応はかなり難しいため、pipianはプログラム的にCaboChaを利用するのではなく、外部コマンドとして実行します。
  - 外部コマンドとして呼ぶだけなので、Windows環境で64bit Rから32bit CaboChaを実行する場合であっても問題なく動作するというメリットがあります。
- エンコーディングの厳格化
  - pipianは、Windows環境であっても、テキストエンコーディングはすべてUTF-8で扱います。このため、MeCabとCaboChaの辞書もあらかじめUTF-8でコンパイルしたものを用意しておく必要があります。

## 使い方

### インストール

GitHubからインストールするため、Windowsでは[Rtools](https://cran.r-project.org/bin/windows/Rtools/)が必要です。

```r
remotes::install_github("paithiov909/pipian")
```

### 係り受け構造のグラフ化

`pipian::ppn_cabocha`に解析したい文字列を渡して、係り受け解析をおこないます。`pipian::ppn_cabocha`は、渡された文書を一時ファイルに書き出し、テキストファイルに対して解析をおこなった結果のXMLファイルへのパスを返します
（このため、`pipian::ppn_cabocha`を実行するためには、MeCabとCaboChaの実行ファイルにパスが通っている必要があります）。

解析結果のXMLファイルは`pipian::ppn_parse_xml`でデータフレームにパースできます。また、この戻り値のデータフレームは`pipian::ppn_plot_igraph`で有向グラフにして確認することができます。

```r
sentence <- "ふと振り向くと、たくさんの味方がいてたくさんの優しい人間がいることを、わざわざ自分の誕生日が来ないと気付けない自分を奮い立たせながらも、毎日こんな、湖のようななんの引っ掛かりもない、落ちつき倒し、音一つも感じさせない人間でいれる方に憧れを持てたとある25歳の眩しき朝のことでした"

sentence %>% 
  pipian::ppn_cabocha() %>% 
  pipian::ppn_parse_xml() %>% 
  pipian::ppn_plot_igraph(sentence_id = 1L)
```

![README-deps1](https://rawcdn.githack.com/paithiov909/pipian/caa2025e073ca43d4dc799fbb765aaae7e28052b/man/figures/README-deps-1.png)

### data.tableへの整形

`pipian::ppn_parse_xml`でパースしたデータフレームは、`pipian::ppn_as_tokenindex`で次のような形のdata.tableに整形することができます。

```r
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

なお、各カラムの値は次のようになっています。

- token: 表層形
- chunk_score: 係り関係のスコア（score）
- POS1~POS4: 品詞, 品詞細分類1, 品詞細分類2, 品詞細分類3
- X5StageUse1: 活用型（五段, 下二段...）
- X5StageUse2: 活用形（連用形, 基本形...）
- Original: 原形
- Yomi1~Yomi2: 読み, 発音
- entity: 固有表現解析の結果の値（IOB2形式）
