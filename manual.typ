#import "src/lib.typ": *

// --------------------------------------------
// Setup: tidy style 
// --------------------------------------------
#import "@preview/tidy:0.1.0"
#let show-type(type) = tidy.styles.minimal.show-type(type)

// --------------------------------------------
// Setup: gentle-clues style 
// --------------------------------------------
#import "@preview/gentle-clues:0.3.0": info, success, warning, error, clue
#let example = clue.with(title: "Example", _color: teal,icon: emoji.page)


// --------------------------------------------
// Setup: Page styling
// --------------------------------------------
#set page(
  numbering: "1/1",
  header: align(right)[The `ionio-illustrate` package],
)

#set heading(numbering: "1.")
#set terms(indent: 1em)
#show link: set text(blue)
#set text(font: "Fira Sans")

// Example code setup
#show raw.where(lang:"typ"): it => block(
  fill: rgb("#F6F4EB"),
  inset: 8pt,
  radius: 5pt,
  width: 100%,
  text(font:"Consolas", it),
)

// --------------------------------------------
// Setup: Example data
// --------------------------------------------
#let data = csv("assets/isobutelene_epoxide.csv")
#let massspec = data.slice(1)

// --------------------------------------------
// Title page(s)
// --------------------------------------------

#align(center, text(16pt)[*The `ionio-illustrate` package*])
#align(center)[Version 0.1.1]

#set par(justify: true, leading: 0.618em)
#v(3em)

= Introduction
This package implements a Cetz chart-like object for displaying mass spectrometric data in Typst documents. It allows for individually styled mass peaks, callouts, titles, and mass callipers.

= Usage
This is the minimal starting point:

#example[```typ
#import "@preview/ionio-illustrate:0.1.1": *
#let data = csv("isobutelene_epoxide.csv")

#let ms = mass-spectrum(massspec, args: (
  size: (12,6),
  range: (0,100),
)) 

#figure((ms.display)())
```]

The above code produces the following content:
#let ms = mass-spectrum(massspec, args: (
  size: (12,6),
  range: (0,100),
) )

#v(1em)
#figure((ms.display)())

It is important to note at this point that the syntax for interacting with mass spectrum objects will certainly change with the introduction of a native type system. This document will be updated to reflect this upon implementation of those changes.

// --------------------------------------------
// Table of Contents
// --------------------------------------------
#pagebreak()
#outline(indent: auto)

// --------------------------------------------
// Documentation Pages
// --------------------------------------------
#pagebreak()
= Documentation
This documentation is generated automatically for each package release, and is guaranteed to be an acurate representation of the API in the strictest of terms, but may lack the additional explanations and examples that make for a good documentation. For a more approachable documentation (at the cost of potentially incorrect descriptions due to oversight), please see the hand-written documentation in @humandoc.

#{
    let module = tidy.parse-module(read("src/lib.typ"))
    tidy.show-module(module, style: tidy.styles.default)
}


// --------------------------------------------
// Humanist Documentation
// --------------------------------------------
#pagebreak()
= Humanist Documentation <humandoc>
This documentation is hand-written, and therefore may sometimes be incorrect if it hasn't been updated to a recent API change (though hopefully those are few). If you see an issue in this documentation, please put in an issue or a pull request on the GitHub repository. That being said, the code examples that run 

== `mass-spectrum()`
The `mass-spectrum()` function takes two positional arguments:
/ `data` (#show-type("array") or #show-type("dictionary")): This is a 2-dimensional array relating mass-charge ratios to their intensities. By default, the first column is the mass-charge ratio and the second column is the intensity.
/ `args` (#show-type("dictionary")): This contains suplemental data that can be used to change the style of the mass spectrum, or to add additional content using provided functions (see @extra-content).
The defaults for the `args` dictionary are shown below:

```typ
keys: (
  mz: 0,
  intensity: 1
),
size: (auto, 1),
range: (40, 400),
style: mass-spectrum-default-style,
labels: (
  x: [Mass-Charge Ratio],
  y: [Relative Intensity (%)]
),
linestyle: (this, idx)=>{},
plot-extras: (this)=>{},
```

// --------------------------------------------
// Humanist Documentation: Keys
// --------------------------------------------
=== `keys`
The `keys` entry in the `args` positional argument is a #show-type("dictionary") that can be used to change which fields in the provided `data` #show-type("array")/#show-type("dictionary") are to be used to plot the mass spectrum. An example usage of this may be to store several mass spectra within a single datafile.

#info[Note that arrays are 0-index based.]

#example[
```typ
#let ms = mass-spectrum(massspec, args: (
  keys: (
    mz: 0, // mass-charge is contained in the first column
    intensity: 1 // intensity is contained in the second column
  )
)) 
```]

// --------------------------------------------
// Humanist Documentation: Size
// --------------------------------------------
=== `size`
The `keys` entry in the `args` positional argument is a tuple specifying the size of the mass spectrum on the page, in `Cetz` units.

#example[```typ
#let ms = mass-spectrum(massspec, args: (
  size: (12,6)
)) 
```]

// --------------------------------------------
// Humanist Documentation: Range
// --------------------------------------------
=== `range`
The `range` entry in the `args` positional argument is a tuple specifying the min and the max of the mass-charge axis.

#example[
```typ
#let ms = mass-spectrum(massspec, args: (
  range: (0,100) // Show mass spectrum between 0 m/z and 100 m/z
)) 
```
]

// --------------------------------------------
// Humanist Documentation: Style
// --------------------------------------------
=== `style`
The `style` entry in the `args` positional argument is a cetz #show-type("style") dictionary. This dictionary accepts 5 entrys, each affecting a different part of the mass spectrum plot:
  / `axes`: This is a style dictionary that is passed to `cetz.axes.scientific` after expansion. Please refer to the Cetz documentation for the subentries that are available (at the time of writing, these include `tick`, `frame`, and `label` among other things)
  / `callouts`: This is passed directly to `cetz.draw.content` after expansion. Please refer to the Cetz documentation for the subentries that are available (at the time of writing, these include `stroke`, `fill`, and `frame`, and `padding`)
  / `peaks`: This is the style passed to all peaks being drawn(overriden by the `linestyle` function). Internally, this is passed to `cetz.draw.line`. Please refer to the Cetz documentation for the subentries that are available (at the time of writing, this include `stroke`)
  / `title`: This is passed directly to `cetz.draw.content` after expansion. Please refer to the Cetz documentation for the subentries that are available (at the time of writing, these include `stroke`, `fill`, and `frame`, and `padding`)
  / `callipers`: This dictionary entry itself is a dictionary that takes `line` (which is passed directly to `cetz.draw.line` after expansion) which allows customisation of the calliper's lines, and `content` (which is passed directly to `cetz.draw.content`) which allows for customizing the content placed above the callipers.

// --------------------------------------------
// Humanist Documentation: Labels
// --------------------------------------------
=== `labels`
The `labels` entry in the `args` positional argument is a dictionary specifying the labels to be used on each axis.

#example[
```typ
#let ms = mass-spectrum(massspec, args: (
  labels: (
    x: [Mass-Charge Ratio],
    y: [Relative Intensity \[%\]]
  )
)) 
```]

#warning[Note that if you provide this entry, you must provide both child entries.]

// --------------------------------------------
// Humanist Documentation: Linestyle
// --------------------------------------------
=== `linestyle`
The `linestyle` entry in the `args` positional argument is a function taking two parameters: `this` (refering to the `#ms` object), and `idx` which is an #show-type("integer") representing the mass-charge ratio of the peak being drawn. Returning a cetz style dictionary will change the appearence of the peaks. This may be used to draw the reader's attention to a particular mass spectrum peak by colouring it in red, for example.

#example[```typ
#let ms = mass-spectrum(massspec, args: (
  linestyle: (this, idx)=>{
      if idx in (41,) {return (stroke: red)}
    }
)) 
```]

// --------------------------------------------
// Humanist Documentation: Plot Extras
// --------------------------------------------
=== `plot-extras` <extra-content>
The `plot-extras` entry in the `args` positional argument is a function taking one parameter, `this`, which refers to the `#ms` object. It can be used to add additional content to a mass spectrum using provided functions

#example[```typ
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
```]

#let data1 = csv("assets/linalool.csv")
#let massspec1 = data1.slice(1)
#let ms2 = mass-spectrum(massspec1, args: (
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
#v(1em)
#figure((ms2.display)())

// --------------------------------------------
// Humanist Documentation: Methods on mass spec object
// --------------------------------------------
// #pagebreak()
== Method functions
This section briefly outlines method functions and where/why they might be used.

// --------------------------------------------
// Humanist Documentation: Display functions
// --------------------------------------------
=== Display function(s)
These are the functions that will render the mass spectrum. For the moment there is only one, though as there are several desirable ways to render a mass spectrum, I envision adding more functions to this.

#warning[Display functions *must not* be called within the context of a `plot-extras(this)` function.]

==== `#ms.display()`
The `#ms.display` method is used to place a mass spectrum within a document. It can be called several times. 

// --------------------------------------------
// Humanist Documentation: Plot extras
// --------------------------------------------
//#pagebreak()
=== `plot-extras` Functions

#warning[The behaviour of `plot-extra` functions is *undefined* when called outside of the context of a `plot-extras(this)` function.]

==== `#ms.title(content)`
The `#ms.title` method allows the addition of a title to a mass spectrum. 

It takes one positional argument, content (#show-type("content") or #show-type("string")).

==== `#ms.callout-above(mz, content: [], y-offset)`
The `#ms.callout-above` method places a callout slightly above the intensity peak for a given mass-charge ratio. 

It takes one positional argument `mz` (#show-type("integer"), #show-type("float"), or #show-type("string")) and two named arguments, `content` (#show-type("content"), #show-type("string"), or #show-type("none")) to be displayed above the mass peak, and `y-offset` (#show-type("length")), which is the distance above the mass peak at which the content is displayed.

- If `content` is #show-type("none"), the default value is that which is provided as `mz`.
- If `height` is #show-type("none"), the default value is `0.3em`.
#text(fill: red)[*TO DO*: Ensure that this value is passed correctly, consider moving it to style]

==== `#ms.callipers(mz1, mz2, content: none, height: none)`
The `#ms.callipers` method places a mass callipers between two mass spectrum peaks, along with any desired content centered above the callipers. 

It takes two positional arguments `mz1` and `mz2` (either of which are #show-type("integer"), #show-type("float"), or #show-type("string")) which represent the start and end of the callipers respectively, and two named arguments, `content` (#show-type("content"), #show-type("string"), or #show-type("none")) which is displayed centered above the callipers, and `height` (#show-type("length")), which is the distance at which the content floats above the mass peak.

- If `content` is #show-type("none"), the default value is to display the negative absolute difference between `mz1` and `mz2`.

- If `height` is #show-type("none"), the default value is `0.3em`.
#text(fill: red)[*TO DO*: Ensure that this value is passed correctly]

#warning[The behaviour is *undefined* when `mz1` is greater in value than `mz2`.]

If `height` is not specified, it is set automatically to a few units above the most intense peak. If `content` is not specified, it is set automatically to represent the loss of mass between the specified peaks.
