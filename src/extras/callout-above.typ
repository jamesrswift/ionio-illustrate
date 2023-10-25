#import "@preview/cetz:0.1.2"

#let _prepare(self, ctx) = {
    if (self.mz <= ctx.prototype.range.at(0) or 
        self.mz >= ctx.prototype.range.at(1) ){ return (:) }

    let data = (if ( ctx.reflected ){ ctx.prototype.data2 } else { ctx.prototype.data1 })
    let y = (ctx.prototype.get-intensity-at-mz)(self.mz, input: data)
    self.coordinates = ( (self.mz, y),)
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

#let callout-above(mz, content:none, inset: 0.3em, ) = {
    if ( content == none ) { content = mz }
    return ((
        type: "call-out",
        mz: mz,
        content: content,
        inset: inset,
        anchors: ("bottom",),
        plot-prepare: _prepare,
        plot-stroke: _stroke,
    ),)
}