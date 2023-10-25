#set par(justify: true)
#set page(width: auto, height: auto, margin:1em)
#set text( size: 7pt)

#import "../src/lib.typ": *

#let linalool-raw = csv("../assets/linalool.csv")
#let linalool = linalool-raw.slice(1)

#let isobut-epoxide-raw = csv("../assets/isobutelene_epoxide.csv")
#let isobut-epoxide = isobut-epoxide-raw.slice(1)

#let args = (
    range: (0,150),
    plot-extras: (this)=>{
        (this.title)([Spectrum Comparison])
        (this.callout-above)(72)
    },
    plot-extras-bottom: (this)=>{
        (this.callout-above)(121)
        (this.callout-above)(93)
        (this.callout-above)(80)
    }
)


#let ms = mass-spectrum(isobut-epoxide, data2:linalool, args: args)
#(ms.display)(mode: "dual-shift")
// #(ms.display)(mode: "dual-shift")
