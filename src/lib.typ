#import "@preview/cetz:0.1.2"

/// Merge dictionary a and b and return the result
/// Prefers values of b.
///
/// - a (dictionary): Dictionary a
/// - b (dictionary): Dictionary b
/// -> dictionary
#let merge-dictionary(a, b, overwrite: true) = {
  if type(a) == dictionary and type(b) == dictionary {
    let c = a
    for (k, v) in b {
      if not k in c {
        c.insert(k, v)
      } else {
        c.at(k) = merge-dictionary(a.at(k), v, overwrite: overwrite)
      }
    }
    return c
  } else {
    return if overwrite {b} else {a}
  }
}

#let mass-spectrum-default-style = (
  axes: (
    tick: (length:-0.1),
    frame: true,
    label: (offset: 0.3)
  ),
  callipers: (
    stroke: gray + 0.7pt
  ),
  callouts: (
    stroke: black
  ),
  peaks: (
    stroke: black
  ),
)

/// Returns an object representing mass spectrum content.
#let mass-spectrum(
  data,
  args: (tick: (length:-0.1))
) = {

  let prototype = (
    
// --------------------------------------------
// Public member data
// --------------------------------------------
    
    data: data,
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

// --------------------------------------------
// "Private" member data
// --------------------------------------------
    
    axes: (
      x: none,
      y: none
    ),
    plot-extras: (this)=>{},

// --------------------------------------------
// Methods : Rendering
// --------------------------------------------
    
    /// The ms.display method is responsible for rendering
    display: (this) => {

      // Setup canvas
      cetz.canvas({

        import cetz.draw: *
        let (x,y) = (this.setup-axes)(this)    

        // Begin group  
        cetz.draw.group(ctx=>{

          // Style
          let style = merge-dictionary(
            merge-dictionary(mass-spectrum-default-style, cetz.styles.resolve(ctx.style, (:), root: "mass-spectrum")),
            this.style
          )

          // Setup scientific axes
          (this.setup-plot)(this, ctx, x, y, ..style.axes)

          cetz.axes.axis-viewport(this.size, x, y,{

            // Add in plot extras first
            (this.plot-extras)(this)

            // Add each individual mass peak
            if this.data.len() > 0 {          
              for (i, row) in data.enumerate() {
                let x = float(row.at(this.keys.mz))
                let y = float(row.at(this.keys.intensity))
                (this.display-single-peak)(this, x, x, y, ..style.peaks)
              }
            }
          })
        })
      })
    },

    // ms.display-single-peak handles the rendering of a single mass peak
    display-single-peak: (this, idx, mz, intensity, ..arguments) => {
      if (mz > this.range.at(0) and mz < this.range.at(1) ){
        cetz.draw.line(
          (mz, 0),
          (rel: (0,intensity)),
          ..arguments, // Global style is overriden by individual style
          ..(this.linestyle)(this, idx)
        )
      }
    },

// --------------------------------------------
// Methods : Property Setup, Internal
// --------------------------------------------

    setup-plot: (this, ctx, x, y, ..arguments) => {
      cetz.axes.scientific(
        size: this.size,
        
        // Axes
        top: none, bottom: x,
        right: none, left: y, // TODO: Optional secondary axis
        ..arguments
      )
    },

    setup-axes: (this) => {
     this.axes.x = cetz.axes.axis(
          min: this.range.at(0), 
          max: this.range.at(1),
          label: this.labels.x,
        )
     this.axes.y = cetz.axes.axis(
          min: 0, 
          max: 110,
          label: this.labels.y,
          ticks: (step: 20, minor-step: none)
        )
      return this.axes
    },

// --------------------------------------------
// Methods : Utility
// --------------------------------------------

    get-intensity-at-mz: (this, mz) => {
      return float(
        (this.data).filter(
          it=>float(it.at(this.keys.mz, default:0))==mz
        ).at(0).at(this.keys.intensity)
      )
    },

// --------------------------------------------
// Methods : Additional Content
// --------------------------------------------

    callout-above: (this, mz, content: none, y-offset: 0.3em) => {
      if ( content == none ) { content = mz}
      // Style
      let style = merge-dictionary(mass-spectrum-default-style, this.style)

      return cetz.draw.content(
        anchor: "bottom",
        (mz, (this.get-intensity-at-mz)(this, mz)), box(inset: y-offset, [#content]),
        ..style.callouts
      )
    },

    callipers: ( this,
      start, end, // mass-charge ratios
      height: none,
      content: none,
      stroke: gray + 0.7pt // Style
    ) => {
      if (content == none){ content = [-#calc.abs(start - end)] }

      // Determine height
      let start_height = (this.get-intensity-at-mz)(this, start)
      let end_height = (this.get-intensity-at-mz)(this, end)
      if ( height == none ) { height = calc.max(start_height, end_height) + 5 }

      let draw-arrow(x, y) = cetz.draw.line(
        (x - 0.5, y + 2),(x + 0.5, y + 2),
        stroke: stroke
      )

      // Draw
      return {
        // Start : horizontal arrow
        draw-arrow(start, start_height)
        draw-arrow(end, end_height)
        
        cetz.draw.merge-path({
          cetz.draw.line( (start, start_height + 2), (start, height) )
          cetz.draw.line((start, height), (end, height))
          cetz.draw.line((end, height),(end, end_height + 2))
        }, stroke: stroke)

        // Content
        cetz.draw.content(
          ( (start + end) / 2, height),
          anchor: "bottom",
          box(inset: 0.3em, content)
        )
      }
    },

    title: (this, content, anchor: "top-left", ..args) => {
      return cetz.draw.content(
        anchor: anchor,
        (this.range.at(0), 110),
        box(inset: 0.5em, content),
        ..args
      )
    }

  )

  // Overrides
  prototype = merge-dictionary(
    prototype,
    args
  )

  prototype.style = merge-dictionary(
    mass-spectrum-default-style,
    prototype.style,
  )

  // Asserts
  assert(type(prototype.keys.mz) in (int, str))
  assert(type(prototype.keys.intensity) in (int, str))

  return prototype
}

#let MolecularIon(charge:none) = [M#super()[#charge+]]