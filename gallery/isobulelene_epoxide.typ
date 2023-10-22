#set par(justify: true)
#set page(width: auto, height: auto, margin:1em)
#set text(font: "Fira Sans", size: 7pt)

#import "../src/lib.typ": *

#let data = csv("../assets/isobutelene_epoxide.csv")
#let massspec = data.slice(1)

#let ms = mass-spectrum(massspec, args: (range: (0,100),)) 

#(ms.display)()