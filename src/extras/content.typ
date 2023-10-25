#import "@preview/cetz:0.1.2"

#let _prepare(self, ctx) = { return self}

#let _stroke(self, ctx) = {
    cetz.draw.content(
        anchor: self.anchors.at(0),
        self.coordinates.at(0),
        self.body
    )
}

#let content(body, position, anchor: "center") = {
    return ((
        type: "raw",
        body: body,
        coordinates: (position,),
        anchors: (anchor,),
        plot-prepare: _prepare,
        plot-stroke: _stroke,
    ),)
}