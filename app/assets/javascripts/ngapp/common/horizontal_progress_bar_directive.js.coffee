angular.module('myApp')
.directive 'horizontalProgressBar', [() ->
  restrict: 'EA'
  scope: {
    module: '='
  }
  link: (scope, elem, attrs) ->
    w = 500
    h = 50

    dataset = [
      [{
        x: 0,
        y: 20 # use student/module progress
      }],
      [{
        x: 0,
        y: 30 # use student/module progress
      }],
      [{
        x: 0,
        y: 90 # use student/module progress
      }]
    ]

    stack = d3.layout.stack()

    # Data, stacked
    stack(dataset)

    # Set up scales
    xScale = d3.scale.linear()
      .domain([0, d3.max(dataset, (d) ->
        d3.max(d, (d) ->
          d.y0 + d.y
        )
      )])
      .range([0, w])

    color = d3.scale.ordinal()
      .range(["#1459D9", "#148DD9", "#87ceeb", "#daa520"])

    # Create SVG element
    svg = d3.select("body")
      .append("svg")
      .attr("width", w)
      .attr("height", h)
      .append("g")

    # Add a group for each row of data
    groups = svg.selectAll("g")
      .data(dataset)
      .enter()
      .append("g")
      .style("fill", (d, i) ->
        color(i)
      )

    # Add a rect for each data value
    rects = groups.selectAll("rect")
      .data((d) ->
        d
      )
      .enter()
      .append("rect")
        .attr("x", (d) ->
          xScale(d.y0)
        )
        .attr("y", 25)
        .attr("height", 25)
        .attr("width", (d) ->
          xScale(d.y)
        )
]
