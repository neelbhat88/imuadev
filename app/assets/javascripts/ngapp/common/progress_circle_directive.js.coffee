angular.module('myApp')
.directive 'progressCircle', [() ->
  restrict: 'EA'
  scope: {
    student: '=',
    width: '=',
    identifier: '@'
  }
  link: (scope, element, attrs) ->
    # 240 current standard width
    width = scope.width
    height = width

    chart = d3.select(element[0])
      .attr("id", scope.student.id + "_" + scope.identifier)
      .append('svg')
      .attr("width", width)
      .attr("height", height)
      .attr("id", "svg" + scope.student.id + "_" + scope.identifier)
      .append("g")
      .attr("transform", "translate(" + (width/2) + "," + (height/2) + ")")

    radius = Math.min(width, height) / 2

    scope.render = (student) ->
      chart.selectAll("g").remove()
      d3.select("#svg" + student.id + "_" + scope.identifier + " circle").remove()
      d3.select("#svg" + student.id + "_" + scope.identifier + " pattern").remove()

      color = d3.scale.ordinal()
        .range(['#41e6b2', '#e8be28', '#ef6629', '#27aae1', '#9665aa', '#808080'])

      data = []
      total_points = 0
      user_points = 0

      for module in student.modules_progress
        user_points += module.points.user
        total_points += module.points.total
        # data[index] = {name: _ref[_i].module_title, value: _ref[_i].points.user}
        data.push({ name: module.module_title, value: module.points.user})

      if total_points == 0
        progress_to_make = 1
      else
        progress_to_make = total_points - user_points

      data[5] = {name: "Future Progress", value: progress_to_make}
      console.log(data)

      arc = d3.svg.arc()
        .outerRadius(radius)
        .innerRadius(radius - ((7/120) * width))

      svg = $('#' + student.id + '_' + scope.identifier + ' svg')[0]

      photoCircle = d3.select(svg)
        .append("circle")
        .attr("cx", width - (width/2))
        .attr("cy", height - (height/2))
        .attr("r", radius-((1/12) * width))
        .style("fill", "url(#photo"+student.id+")")

      image = d3.select(svg)
        .append("pattern")
        .attr("id", "photo" + student.id)
        .attr("x", 0)
        .attr("y", 0)
        .attr("width", 1)
        .attr("height", 1)
        .append("image")
        .attr("x", 0)
        .attr("y", 0)
        .attr("width", width - ((1/6) * width))
        .attr("height", height - ((1/6) * height))
        .attr("xlink:href", student.square_avatar_url)

      arc2 = d3.svg.arc().outerRadius(radius - ((1/6) * width))

      myScale = d3.scale.linear().domain([0, 360]).range([0, 2 * Math.PI])

      pie = d3.layout.pie()
        .sort(null)
        .startAngle(myScale(0))
        .endAngle(myScale(360))
        .value((d) -> d.value)

      g = chart.selectAll(".arc")
        .data(pie(data))
        .enter().append("g")
        .attr("class", "arc")

      tweenPie = (b) ->
        i = d3.interpolate({startAngle: myScale(0), endAngle: myScale(0)}, b)
        (t) ->
          arc(i(t))

      g.append("path")
        .attr("fill", (d, i) -> color(i))
        .transition()
          .duration(800)
          .attrTween("d", tweenPie)

    scope.$watch('student', () ->
      scope.render(scope.student)
    , true)
]
