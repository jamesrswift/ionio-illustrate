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
        (this.title)([Isobutelene Epoxide])
        (this.callout-above)(72)
    },
    plot-extras-bottom: (this, reflected: false)=>{
        (this.title)([Linalool, NIST Library 2017], reflected: reflected)
        (this.callout-above)(121, reflected: reflected)
        (this.callout-above)(93, reflected: reflected)
        (this.callout-above)(80, reflected: reflected)
    }
)


#let ms = mass-spectrum(isobut-epoxide, data2:linalool, args: args)
#(ms.display)(mode: "dual-reflection")
// #(ms.display)(mode: "dual-shift")
