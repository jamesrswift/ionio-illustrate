#set par(justify: true)
#set page(width: auto, height: auto, margin:1em)
#set text(font: "Fira Sans", size: 7pt)

#import "../src/lib.typ": *

#let linalool-raw = csv("../assets/linalool.csv")
#let linalool = linalool-raw.slice(1)

#let isobut-epoxide-raw = csv("../assets/isobutelene_epoxide.csv")
#let isobut-epoxide = isobut-epoxide-raw.slice(1)

#let args = (
    range: (0,150),
)


#let ms = mass-spectrum(isobut-epoxide, data2:linalool, args: args)

#(ms.display)(mode: "dual-reflection")
