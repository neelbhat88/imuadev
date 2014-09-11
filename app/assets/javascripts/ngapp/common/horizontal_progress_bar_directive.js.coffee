angular.module('myApp')
.directive 'horizontalProgressBar', [() ->
  restrict: 'EA'
  scope: {
    student: '='
  }
  link: (scope, element, attrs) ->
    w = 500
    h = 50

    progressData = []

    console.log(scope.student)
    user_points = 0
    total_points = 0

    for module in scope.student.modules_progress
      progressData.push([{ x: 0, y: module.points.user}])
      user_points += module.points.user
      total_points += module.points.total

    if total_points == 0
      progress_to_make = 1
    else
      progress_to_make = total_points - user_points

    progressData[5] = [{ x: 0, y: progress_to_make}]

    stack = d3.layout.stack()

    # Data, stacked
    stack(progressData)

    # Set up scales
    xScale = d3.scale.linear()
      .domain([0, d3.max(progressData, (d) ->
        d3.max(d, (d) ->
          d.y0 + d.y
        )
      )])
      .range([0, w])

    color = d3.scale.ordinal()
        .range(['#41e6b2', '#e8be28', '#ef6629', '#27aae1', '#9665aa', '#808080']);

    # Create SVG element
    svg = d3.select("body")
      .append("svg")
      .attr("width", w)
      .attr("height", h)
      .append("g")

    # Add a group for each row of data
    groups = svg.selectAll("g")
      .data(progressData)
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
