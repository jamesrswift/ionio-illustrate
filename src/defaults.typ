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
    stroke: black + 0.55pt
  ),
  data1: (peaks: (stroke: blue + 0.55pt)),
  data2: (peaks: (stroke: red + 0.55pt)),
)