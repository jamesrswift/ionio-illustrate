#import "@preview/cetz:0.1.2"

#let _prepare(self, ctx) = {
    self.coordinates = ( (ctx.prototype.range.at(0), 110),)
    return self
}

#let _stroke(self, ctx) = {
    cetz.draw.content(
      anchor: self.anchors.at(0),
      self.coordinates.at(0),
      //(72, 80),
      box(inset: self.inset, [#self.content]),
      //..ctx.prototype.style.callouts
    )
}

#let title(content, inset: 0.5em) = {
    return ((
        type: "title",
        content: content,
        inset: inset,
        anchors: ("top-left",),
        plot-prepare: _prepare,
        plot-stroke: _stroke,
    ),)
}