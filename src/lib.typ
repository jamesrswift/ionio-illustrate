#import "@preview/cetz:0.1.2"
#import "util.typ": *
#import "defaults.typ": *

#let mass-spectrum-modes =(
  "single", "dual-reflection"
)

/// Returns an object representing mass spectrum content.
///
/// - data1 (array): The mass spectrum in the format of a 2D array, or an array of dictionarys.
///         By default, the mass-charges ratios are in the first column, and the relative
///         intensities are in the second column.
/// - data2 (array): similar format as `data1`, but to contain a second mass spectrum.
/// - args (dictionary): Override default behaviour of the mass spectrum by overriding methods,
///         or setting fields.
/// -> dictionary, none
#let mass-spectrum(
  args: (:),
  data1, data2: none,
) = {

  let prototype = (
    
// --------------------------------------------
// Public member data
// --------------------------------------------

    data1: data1,
    data2: data2,
    keys: (
      mz: 0,
      intensity: 1
    ),
    size: (14,5),
    range: (40, 400),
    style: mass-spectrum-default-style,
    labels: (
      x: [Mass-Charge Ratio],
      y: [Relative Intensity (%)]
    ),
    linestyle: (this, idx)=>{},
    plot-extras: (this)=>{},
    plot-extras-bottom: (this)=>{},
  )

  // Asserts
  assert(type(prototype.keys.mz) in (int, str))
  assert(type(prototype.keys.intensity) in (int, str))

  // Overrides. This ensures the prototype is properly formed by the time we need it
  prototype = merge-dictionary(prototype,args)
  prototype.style = merge-dictionary(mass-spectrum-default-style,prototype.style)


// --------------------------------------------
// Methods : Utility
// --------------------------------------------

  /// Get the intensity of a mass-peak for a given mass-charge ratio
  //
  // - mz (string, integer, float): Mass-charge ratio for which the intensity is being queried
  // -> float
  prototype.get-intensity-at-mz = (mz) => {

    // TODO: Handle reflections

    let intensity_arr = (prototype.data1).filter(
        it=>float(it.at(prototype.keys.mz, default:0))==mz
      )
    if ( intensity_arr.len() == 0 ) {return 0}
    return float(
      intensity_arr.at(0).at(prototype.keys.intensity)
    )
  }

// --------------------------------------------
// Methods : Additional Content
// --------------------------------------------

  // Plot-extras function that will place content above a mass peak
  // - mz (string, integer, float): Mass-charge above which to display content
  // - content (content, string, none): Content to show above mass peak. Defaults to given mz
  // - y-offset (length): Distance at which to display content above mass peak
  // -> content
  prototype.callout-above = (mz, content: none, y-offset: 0.3em) => {
    if ( mz <= prototype.range.at(0) or mz >= prototype.range.at(1) ){ return }
    if ( content == none ) { content = mz}

    // TODO: Handle reflections

    return cetz.draw.content(
      anchor: "bottom",
      (mz, (prototype.get-intensity-at-mz)(mz)), box(inset: y-offset, [#content]),
      ..prototype.style.callouts
    )
  }

  prototype.callipers = (
    start, end, // mass-charge ratios
    height: none,
    content: none,
  ) => {
    if (content == none){ content = [-#calc.abs(start - end)] }

    // TODO: Handle reflections

    // Determine height
    let start_height = (prototype.get-intensity-at-mz)(start)
    let end_height = (prototype.get-intensity-at-mz)(end)
    if ( height == none ) { height = calc.max(start_height, end_height) + 5 }

    let draw-arrow(x, y) = cetz.draw.line(
      (x - 0.5, y + 2),(x + 0.5, y + 2),
      ..prototype.style.callipers.line
    )

    // Draw
    return {
      // Start : horizontal arrow
      draw-arrow(start, start_height)
      draw-arrow(end, end_height)
      
      cetz.draw.merge-path({
        cetz.draw.line((start, start_height + 2), (start, height))
        cetz.draw.line((start, height), (end, height))
        cetz.draw.line((end, height),(end, end_height + 2))
      }, ..prototype.style.callipers.line)

      // Content
      cetz.draw.content(
        ( (start + end) / 2, height),
        anchor: "bottom",
        box(inset: 0.3em, content),
        ..prototype.style.callipers.content
      )
    }
  }

  prototype.title = (content, anchor: "top-left", ..args) => {

    // TODO: Handle reflections

    return cetz.draw.content(
      anchor: anchor,
      (prototype.range.at(0), 110),
      box(inset: 0.5em, content),
      ..prototype.style.title,
      ..args
    )
  }

// --------------------------------------------
// Methods : Property Setup, Internal
// --------------------------------------------

  prototype.setup-plot = (ctx, x, y, ..arguments) => {
    cetz.axes.scientific(
      size: prototype.size,
      
      // Axes
      top: none, bottom: x,
      right: none, left: y, // TODO: Optional secondary axis
      ..arguments
    )
  }

  prototype.setup-axes = (reflection: false) => {

    let axes = (:)
    axes.x = cetz.axes.axis(
      min: prototype.range.at(0), 
      max: prototype.range.at(1),
      label: prototype.labels.x,
      //ticks: (step: 10, minor-step: none)
    )
    axes.y = cetz.axes.axis(
      min: if reflection {-115} else {0}, 
      max:  if reflection {115} else {110},
      label: prototype.labels.y,
      ticks: (step: if reflection {40} else {20}, minor-step: none)
    )
    return axes
  }


// --------------------------------------------
// Methods : Rendering
// --------------------------------------------

  // ms.display-single-peak handles the rendering of a single mass peak
  prototype.display-single-peak = (idx, mz, intensity, arguments) => {
    if (mz > prototype.range.at(0) and mz < prototype.range.at(1) ){
      cetz.draw.line(
        (mz, 0),
        (rel: (0,intensity)),
        ..arguments, // Global style is overriden by individual style
        ..(prototype.linestyle)(prototype, idx)
      )
    }
  }

  prototype.display-single-data = (dataset, style, scale: 1, dx: 0) => {
    if dataset.len() > 0 {          
      for (i, row) in dataset.enumerate() {
        let x = float(row.at(prototype.keys.mz))
        let y = float(row.at(prototype.keys.intensity))
        (prototype.display-single-peak)(x, x + dx, y * scale, style)
      }
    }
  }

  // The ms.display-single method is responsible for rendering
  // a single mass spectra plot
  prototype.display-single = (ctx) => {
    import cetz.draw: *  
    let (x,y) = (prototype.setup-axes)()  

    // Style
    let style = merge-dictionary(
      merge-dictionary(mass-spectrum-default-style, cetz.styles.resolve(ctx.style, (:), root: "mass-spectrum")),
      prototype.style
    )

    // Setup scientific axes
    (prototype.setup-plot)(ctx, x, y, ..style.axes)

    cetz.axes.axis-viewport(prototype.size, x, y,{
      (prototype.plot-extras)(prototype)
      (prototype.display-single-data)(prototype.data1, style.peaks)
    })   

  }

  // The ms.display-dual-reflection method is responsible for rendering
  // multiple mass spectra on the same plot
  prototype.display-dual-reflection = (ctx) => {

    // If there is only one dataset, fail safely quickly
    if ( prototype.data2 == none){
      return (prototype.display-single)(ctx)
    }

    import cetz.draw: *  
    let (x,y) = (prototype.setup-axes)(reflection: true)

    // Style
    let style = merge-dictionary(
      merge-dictionary(mass-spectrum-default-style, cetz.styles.resolve(ctx.style, (:), root: "mass-spectrum")),
      prototype.style
    )
    let style-data1 = merge-dictionary(style, prototype.style.data1).peaks
    let style-data2 = merge-dictionary(style, prototype.style.data2).peaks

    // Setup scientific axes
    (prototype.setup-plot)(ctx, x, y, ..style.axes)

    cetz.axes.axis-viewport(prototype.size, x, y,{
      (prototype.plot-extras)(prototype)
      (prototype.display-single-data)(prototype.data1, style-data1, scale: 1)
      cetz.draw.line((prototype.range.at(0), 0), (prototype.range.at(1), 0))
      (prototype.plot-extras-bottom)(prototype)
      (prototype.display-single-data)(prototype.data2, style-data2, scale: -1)
    })
  }

  /// The ms.display method is responsible for rendering
  prototype.display = (mode: "single") => {

    assert(mode in mass-spectrum-modes, message: "Invalid mass-spectrum mode")

    let render = (
      if mode == "single" {prototype.display-single} else
      if mode == "dual-reflection" {prototype.display-dual-reflection} 
    )

    // Setup canvas
    cetz.canvas(cetz.draw.group(render))
  }

  return prototype
}

#let MolecularIon(charge:none) = [M#super()[#charge+]]