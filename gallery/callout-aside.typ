#set par(justify: true)
#set page(width: auto, height: auto, margin:1em)
#set text(size: 7pt)

#import "../src/lib.typ": *

#let data = csv("../assets/isobutelene_epoxide.csv")
#let massspec = data.slice(1)

#let ms = mass-spectrum(massspec, args: (range: (0,100),

plot-extras: (this) => {

    (this.callout-above)(43)
    (this.callout-aside)(41, (44, 90), anchor: "left", height: 95%)
    (this.callout-aside)(42, (45, 65), anchor: "left", height: 95%)
    (this.title)([Isobuletene Epoxide, +70eV])
  },)) 

#(ms.display)()