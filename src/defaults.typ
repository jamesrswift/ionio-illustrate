#let mass-spectrum-default-style = (
  axes: (
    tick: (length:-0.1),
    frame: true,
    label: (offset: 0.3)
  ),
  title: (:),
  callipers: (
    line: (stroke: gray + 0.7pt),
    content: (:)
  ),
  callouts: (
    stroke: black
  ),
  peaks: (
    stroke: black + 0.7pt
  ),
  data1: (peaks: (stroke: blue + 0.7pt)),
  data2: (peaks: (stroke: red + 0.7pt)),
)