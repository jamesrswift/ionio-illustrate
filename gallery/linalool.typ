#set par(justify: true)
#set page(width: auto, height: auto, margin:1em)
#set text(font: "Fira Sans", size: 7pt)

#import "../src/lib.typ": *

#let data = csv("../assets/linalool.csv")
#let massspec = data.slice(1)

#let ms = mass-spectrum(massspec, args: (
  range: (0,150),
  plot-extras: (this) => {
    (this.callout-above)(136, content: MolecularIon())
    (this.callout-above)(121)
    (this.callout-above)(93)
    (this.callout-above)(80)
    (this.callout-above)(71)
    (this.callipers)(41, 55, content: [-CH#sub[2]])
    (this.title)([Linalool, +70eV])
  },
  linestyle: (this, mz)=>{
    if mz in (93,) { return (stroke: red) }
    if mz in (71,) { return (stroke: blue) }
  }
)) 
#(ms.display)()