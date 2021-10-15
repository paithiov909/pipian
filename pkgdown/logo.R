library(usethis)
library(pkgdown)
library(hexSticker)

img <- file.path(getwd(),
    "man",
    "figures",
    "pumpkin.svg"
)

hexSticker::sticker(
    img,
    s_x = 1,
    s_width = .5,
    s_height = .5,
    p_size = 32,
    package = "pipian",
    p_color = "#2A7AFA",
    h_size = 2.4,
    h_fill = "#233E4A",
    h_color = "#FA2A7A",
    filename = "man/figures/logo-origin.png"
)

use_logo("man/figures/logo-origin.png")
build_favicons(overwrite = TRUE)

