#set par(justify: true)
#set page(width: auto, height: auto, margin:1em)
#set text(font: "Fira Sans")

#import "../src/lib.typ": *

#let data = csv("../assets/linalool.csv")
#let massspec = data.slice(1)

#let ms = mass-spectrum(massspec, args: (
  size: (12,6),
  range: (0,100),
)) 

#(ms.display)()