= Model
$ Y_alpha = beta_(i, j) X_(i, j) + gamma_i + lambda_j + beta_0 + epsilon_(i, j) $
Where $Y$ is the count of establishments in some retail category $alpha$, $X$ is a dummy variable for gentrification
in a zipcode belonging to CBSA $i$ in year $j$,
$gamma_i$ is the fixed effect for CBSA $i$,
$lambda_j$ is the fixed effect for year $j$,
$beta_0$ is some constant,
and $epsilon$ is the error term.

#show figure: set block(breakable: false)
#figure( // start preamble figure
  
  kind: table, // end preamble figure

block[ // start block

  #let style-dict = (
    // tinytable style-dict after
    "0_1": 0, "1_1": 0, "2_1": 0, "3_1": 0, "4_1": 0, "5_1": 0, "6_1": 0, "7_1": 0, "8_1": 0, "0_2": 0, "1_2": 0, "2_2": 0, "3_2": 0, "4_2": 0, "5_2": 0, "6_2": 0, "7_2": 0, "8_2": 0, "0_3": 0, "1_3": 0, "2_3": 0, "3_3": 0, "4_3": 0, "5_3": 0, "6_3": 0, "7_3": 0, "8_3": 0, "0_4": 0, "1_4": 0, "2_4": 0, "3_4": 0, "4_4": 0, "5_4": 0, "6_4": 0, "7_4": 0, "8_4": 0, "0_0": 1, "1_0": 1, "2_0": 1, "3_0": 1, "4_0": 1, "5_0": 1, "6_0": 1, "7_0": 1, "8_0": 1
  )

  #let style-array = ( 
    // tinytable cell style after
    (align: center,),
    (align: left,),
  )

  // Helper function to get cell style
  #let get-style(x, y) = {
    let key = str(y) + "_" + str(x)
    if key in style-dict { style-array.at(style-dict.at(key)) } else { none }
  }

  #show table.cell: it => {
    if style-array.len() == 0 { return it }
    
    let style = get-style(it.x, it.y)
    if style == none { return it }
    
    let tmp = it
    if ("fontsize" in style) { tmp = text(size: style.fontsize, tmp) }
    if ("color" in style) { tmp = text(fill: style.color, tmp) }
    if ("indent" in style) { tmp = pad(left: style.indent, tmp) }
    if ("underline" in style) { tmp = underline(tmp) }
    if ("italic" in style) { tmp = emph(tmp) }
    if ("bold" in style) { tmp = strong(tmp) }
    if ("mono" in style) { tmp = math.mono(tmp) }
    if ("strikeout" in style) { tmp = strike(tmp) }
    if ("smallcaps" in style) { tmp = smallcaps(tmp) }
    tmp
  }

  // tinytable align-figure before
  #let tinytable-coldata = (
    ([ ], [Gentrifying], [], [Num.Obs.], [R2], [R2 Adj.], [AIC], [BIC], [RMSE]),
    ([Dollar Stores], [\-0.76\*\*\*], [(0.13)], [3049], [0.237], [0.233], [13115.9], [13224.3], [2.07]),
    ([Fast Food], [0.55\*], [(0.26)], [3049], [0.134], [0.130], [17534.4], [17642.8], [4.27]),
    ([Cafes], [11.90\*\*\*], [(0.47)], [3049], [0.326], [0.322], [21236.6], [21345.0], [7.83]),
    ([Arts\/Ent], [7.71\*\*\*], [(0.45)], [3049], [0.125], [0.120], [20889.9], [20998.3], [7.40]),
  )

  #context layout(size => {
    let tinytable-naturals = tinytable-coldata.map(col => measure(grid(columns: 1, inset: 5pt, ..col)).width)
    let tinytable-total = calc.min(tinytable-naturals.sum(), size.width)
    block(width: tinytable-total)[

  #table( // tinytable table start
    columns: tinytable-naturals.map(w => w.pt() * 1fr),
    stroke: none,
    rows: auto,
    align: (x, y) => {
      let style = get-style(x, y)
      if style != none and "align" in style { style.align } else { left }
    },
    fill: (x, y) => {
      let style = get-style(x, y)
      if style != none and "background" in style { style.background }
    },
 table.hline(y: 1, start: 0, end: 5, stroke: 0.05em),
 table.hline(y: 3, start: 0, end: 5, stroke: 0.05em),
 table.hline(y: 9, start: 0, end: 5, stroke: 0.08em),
 table.hline(y: 0, start: 0, end: 5, stroke: 0.08em),
    // tinytable lines before

    // tinytable header start
    table.header(
      repeat: true,
[ ], [Dollar Stores], [Fast Food], [Cafes], [Arts\/Ent],
    ),
    // tinytable header end

    // tinytable cell content after
[Gentrifying], [\-0.76\*\*\*], [0.55\*], [11.90\*\*\*], [7.71\*\*\*],
[], [(0.13)], [(0.26)], [(0.47)], [(0.45)],
[Num.Obs.], [3049], [3049], [3049], [3049],
[R2], [0.237], [0.134], [0.326], [0.125],
[R2 Adj.], [0.233], [0.130], [0.322], [0.120],
[AIC], [13115.9], [17534.4], [21236.6], [20889.9],
[BIC], [13224.3], [17642.8], [21345.0], [20998.3],
[RMSE], [2.07], [4.27], [7.83], [7.40],

    // tinytable footer after

    table.footer(
      repeat: false,
      // tinytable notes after
    table.cell(align: left, colspan: 5, text([\+ p \< 0.1, \* p \< 0.05, \*\* p \< 0.01, \*\*\* p \< 0.001])),
    ),
    

  ) // end table

  ]
  })

  // tinytable align-figure after

] // end block
) // end figure

#pagebreak()

#figure(image("figures/boston_map_12.png", width: 150%))
#figure(image("figures/boston_map_15.png", width: 150%))
#figure(image("figures/boston_map_20.png", width: 150%))
#figure(image("figures/boston_map_22.png", width: 150%))
