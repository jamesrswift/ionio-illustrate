#set par(justify: true)
#set page(width: auto, height: auto, margin:1em)
#set text(font: "Fira Sans", size: 7pt)

#import "../src/lib.typ": *

#let data = csv("../assets/linalool.csv")
#let massspec = data.slice(1)

#let ms = mass-spectrum(massspec, args: (
  size: (14,5),
  range: (0,150),
  /*style: (stroke: 5pt),*/
  plot-extras: (this) => {
    (this.callout-above)(this, 136, content: MolecularIon())
    (this.callout-above)(this, 121)
    (this.callout-above)(this, 93)
    (this.callout-above)(this, 80)
    (this.callout-above)(this, 71)
    (this.callipers)(this, 41, 55, content: [-CH#sub[2]])
    (this.title)(this, [Linalool, +70eV])
  },
  linestyle: (this, mz)=>{
    if mz in (93,) { return (stroke: red) }
    if mz in (71,) { return (stroke: blue) }
  },
  style: (
    peaks: (
      stroke: green,
    )
  )
)) 
#(ms.display)(ms)