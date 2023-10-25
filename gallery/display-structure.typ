#set par(justify: true)
#set page(width: auto, height: auto, margin:1em)
#set text(size: 7pt)

#import "../src/lib.typ": *

#let data = csv("../assets/linalool.csv")
#let massspec = data.slice(1)

#let ms = mass-spectrum(massspec, args: (
  range: (0,150),
  plot-extras: (this) => {
    (this.callout-above)(121)
    (this.title)([Linalool, +70eV])
    (this.content)(
      box(
        image("../assets/Linalool_skeletal.svg", height: 3.5em),
        inset: 0.5em
      ),
      (2,100),
      anchor: "top-left"
    )

  },
  linestyle: (this, mz)=>{
    if mz in (93,) { return (stroke: red) }
    if mz in (71,) { return (stroke: blue) }
  },

)) 
#(ms.display)()