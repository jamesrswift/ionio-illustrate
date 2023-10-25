#import "@preview/cetz:0.1.2"

#let _prepare(self, ctx) = { return self}

#let _stroke(self, ctx) = {
    self.body
}

#let cetz-raw(body, inset: 0.3em, ) = {
    return ((
        type: "raw",
        body: body,
        plot-prepare: _prepare,
        plot-stroke: _stroke,
    ),)
}