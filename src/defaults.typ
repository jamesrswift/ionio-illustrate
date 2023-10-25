#let mass-spectrum-default-style = (
  axes: (
    tick: (length:-0.1, stroke: 0.4pt),
    frame: true,
    label: (offset: 0.3),
    stroke: 0.4pt
  ),
  title: (:),
  callipers: (
    line: (stroke: gray + 0.45pt),
    content: (:)
  ),
  callouts: (
    line: (stroke: gray + 0.45pt),
  ),
  peaks: (
    stroke: (paint: black, thickness: 0.55pt, cap: "butt")
  ),
  data1: (peaks: (stroke: (paint: blue, thickness: 0.55pt, cap: "butt"))),
  data2: (peaks: (stroke: (paint: red, thickness: 0.55pt, cap: "butt"))),
  shift-amount: 0.13
)