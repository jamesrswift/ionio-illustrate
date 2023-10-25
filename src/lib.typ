#import "@preview/cetz:0.1.2"
#import "util.typ": *
#import "defaults.typ": *
#import "extras.typ"

#let mass-spectrum-modes =(
  "single", "dual-reflection", "dual-shift"
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

// --------------------------------------------
// "Private" member data
// --------------------------------------------
    _reflected: false


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
  prototype.get-intensity-at-mz = (mz, input: auto) => {

    let data = (if input == auto {prototype.data1} else {input})

    // Search all mz matching query
    let intensity_arr = data.filter(
      it=>float(it.at(prototype.keys.mz, default:0))==mz
    )

    if ( intensity_arr.len() == 0 ) {return 0}

    // Return "first" hit
    return float(
      intensity_arr.at(0).at(prototype.keys.intensity)
    )
  }

// --------------------------------------------
// Methods : Additional Content
// --------------------------------------------

  prototype.callout-above = extras.callout-above
  prototype.callout-aside = extras.callout-aside
  prototype.callipers = extras.callipers
  prototype.title = extras.title

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
      min: if reflection {-110} else {0}, 
      max:  110,
      label: prototype.labels.y,
      ticks: (step: if reflection {40} else {20}, minor-step: none)
    )
    return axes
  }


// --------------------------------------------
// Methods : Rendering
// --------------------------------------------

  prototype.display-extras = (body, axes: (:), sy: 1, dx: 0, plot-ctx: (:)) => {

    // Assert we are drawing commands
    let body = if body != none { body } else { () }
    for cmd in body {
      assert(
        type(cmd) == dictionary and "type" in cmd,
        message: "Expected plot sub-command in plot body, got " + repr(cmd)
      )
    }

    // Prepare
    for i in range(body.len()) {
      if "plot-prepare" in body.at(i) {
        body.at(i) = (body.at(i).plot-prepare)(body.at(i), plot-ctx)
      }
    }

    // Transform coordinates
    for i in range(body.len()) {
      if "coordinates" in body.at(i).keys() { 
        body.at(i).coordinates = map( body.at(i).coordinates, (it) => {
          (it.at(0) + dx, it.at(1) * sy)
        })
      }

      if ( sy < 0 ){
        if "anchors" in body.at(i).keys() { 
          body.at(i).anchors = body.at(i).anchors.map( (it) => {
            if it == "bottom" {return "top"}
            if it == "top-left" {return "bottom-left"}
          })
        }
      }
    }

    // panic(body)

    // Stroke + Mark data
    for d in body {      
      //cetz.axes.axis-viewport(prototype.size, axes.x, axes.y, {
      //  cetz.draw.anchor("center", (0, 0))
        if "style" in d {cetz.draw.set-style(..d.style)}
        if "plot-fill" in d {(d.plot-fill)(d, plot-ctx)}
        if "plot-stroke" in d {(d.plot-stroke)(d, plot-ctx)}
      //})
    }
  }

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
      // Prepare context argument
      let plot-ctx = (prototype: prototype, reflected: false)
      
      // Draw top mass spectrum
      (prototype.display-extras)(
        (prototype.plot-extras)(prototype), 
        axes: (x:x, y:y),
        plot-ctx: plot-ctx
      )
      (prototype.display-single-data)(prototype.data1, style.peaks)
    })   

  }

  // The ms.display-dual-reflection method is responsible for rendering
  // multiple mass spectra on the same plot by reflecting one of the plots
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

      // Prepare context argument
      let plot-ctx = (prototype: prototype, reflected: false)
      
      // Draw top mass spectrum
      (prototype.display-extras)(
        (prototype.plot-extras)(prototype), 
        axes: (x:x, y:y),
        plot-ctx: plot-ctx
      )
      (prototype.display-single-data)(prototype.data1, style-data1, scale: 1)

      // Draw bottom mass spectrum
      let plot-ctx = (prototype: prototype, reflected: true)
      (prototype.display-extras)(
        (prototype.plot-extras-bottom)(prototype), 
        axes: (x:x, y:y),
        sy: -1,
        plot-ctx: plot-ctx
      )
      (prototype.display-single-data)(prototype.data2, style-data2, scale: -1)

      // Draw mid-line
      cetz.draw.line((prototype.range.at(0), 0), (prototype.range.at(1), 0), ..style.axes)
    })
  }

  // The ms.display-dual-shift method is responsible for rendering
  // multiple mass spectra on the same plot by shifting one of the plots
  prototype.display-dual-shift = (ctx) => {

    // If there is only one dataset, fail safely quickly
    if ( prototype.data2 == none){
      return (prototype.display-single)(ctx)
    }

    import cetz.draw: *  
    let (x,y) = (prototype.setup-axes)()

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
      // Prepare context argument
      let plot-ctx = (prototype: prototype, reflected: false)
      
      // Draw top mass spectrum
      (prototype.display-extras)(
        (prototype.plot-extras)(prototype), 
        axes: (x:x, y:y), dx:-0.25,
        plot-ctx: plot-ctx
      )
      (prototype.display-single-data)(prototype.data1, style-data1, dx:-0.25)

      // Draw bottom mass spectrum
      let plot-ctx = (prototype: prototype, reflected: true)
      (prototype.display-extras)(
        (prototype.plot-extras-bottom)(prototype), 
        axes: (x:x, y:y), dx:+0.25,
        plot-ctx: plot-ctx
      )
      (prototype.display-single-data)(prototype.data2, style-data2, dx:+0.25)
    })
  }

  /// The ms.display method is responsible for rendering
  prototype.display = (mode: "single") => {

    assert(mode in mass-spectrum-modes, message: "Invalid mass-spectrum mode")

    let render = (
      if mode == "single" {prototype.display-single} else
      if mode == "dual-reflection" {prototype.display-dual-reflection} else
      if mode == "dual-shift" {prototype.display-dual-shift} 
    )

    // Setup canvas
    cetz.canvas(cetz.draw.group(render))
  }

  return prototype
}

#let MolecularIon(charge:none) = [M#super()[#charge+]]