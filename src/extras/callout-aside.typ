#import "@preview/cetz:0.1.2"

#let _prepare(self, ctx) = {
    if (self.mz <= ctx.prototype.range.at(0) or 
        self.mz >= ctx.prototype.range.at(1) ){ return (:) }

    let data = (if ( ctx.reflected ){ ctx.prototype.data2 } else { ctx.prototype.data1 })
    let y = (ctx.prototype.get-intensity-at-mz)(self.mz, input: data)

    if self.height == auto {self.height = 100%}
    if type(self.height) == ratio {
        self.height =  y * (self.height / 100%)
    }

    self.coordinates = ( 
        mass-peak: (self.mz, self.height),
        content: self.position,
    )

    return self
}

#let _stroke(self, ctx) = {

    cetz.draw.line(
        self.coordinates.mass-peak,
        self.coordinates.content,
        ..ctx.prototype.style.callouts.line
    )

    cetz.draw.content(
      anchor: self.anchors.at(0),
      self.coordinates.content,
      //(72, 80),
      box(inset: self.inset, [#self.content]),
      ..ctx.prototype.style.callouts
    )
}

#let callout-aside(
    mz,
    position,
    height: auto,
    content: none,
    anchor: "bottom",
    inset: 0.1em) = {
    if ( content == none ) { content = mz }
    return ((
        type: "callout-aside",
        mz: mz,
        content: content,
        height: height,
        position: position,
        anchors: (anchor,),
        inset: inset,
        plot-prepare: _prepare,
        plot-stroke: _stroke,
    ),)
}

