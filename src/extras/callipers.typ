#import "@preview/cetz:0.1.2"

#let _prepare(self, ctx) = {

    let data = (if ( ctx.reflected ){ ctx.prototype.data2 } else { ctx.prototype.data1 })

    let start_height = (ctx.prototype.get-intensity-at-mz)(self.start, input: data) + 2
    let end_height = (ctx.prototype.get-intensity-at-mz)(self.end, input: data) + 2

    if ( self.height == none ) { self.height = calc.max(start_height, end_height) + 5 }

    self.coordinates = (
        // mz1
        mz1-stalk-lower: (self.start,start_height),
        mz1-stalk-upper: (self.start,self.height),
        
        // mz2
        mz2-stalk-lower: (self.end,end_height),
        mz2-stalk-upper: (self.end,self.height),

        // Content
        content: ((self.start+self.end)/2,self.height),
    )
    return self
}

#let _stroke(self, ctx) = {

    let draw-arrow( pos ) = cetz.draw.line(
      (pos.at(0) - (self.arrow-width / 2), pos.at(1) ), (rel:(self.arrow-width, 0)),
      ..ctx.prototype.style.callipers.line
    )

    let coords = self.coordinates

    draw-arrow(coords.mz1-stalk-lower)
    draw-arrow(coords.mz2-stalk-lower)

    cetz.draw.line(
        coords.mz1-stalk-lower,
        coords.mz1-stalk-upper,
        coords.mz2-stalk-upper,
        coords.mz2-stalk-lower,
        ..ctx.prototype.style.callipers.line
    )

    cetz.draw.content(
      coords.content,
      anchor: self.anchors.at(0),
      box(inset: self.inset, [#self.content]),
      //..ctx.prototype.style.callouts
    )

}

//  maybe need inset
#let callipers( start, end, // mass-charge ratios
                height: none,
                content: none,
                arrow-width: 1,
                inset: 0.5em) = {

    if (content == none){ content = [-#calc.abs(start - end)] }

    return ((
        type: "callipers",
        start: start,
        end: end,
        height: height,
        content: content,
        arrow-width: arrow-width,
        inset: inset,
        anchors: ("bottom",),
        plot-prepare: _prepare,
        plot-stroke: _stroke,
    ),)
}
