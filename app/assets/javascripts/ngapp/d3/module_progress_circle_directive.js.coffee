angular.module('myApp')
.directive 'moduleProgressCircle', [ () ->
  restrict: 'EA',
  scope: {
    module: '=',
    width: '=',
    parentclass: '@'
  }
  link: (scope, element, attrs) ->
    if scope.parentclass
      width = $('.' + scope.parentclass).outerWidth()
      height = width
    else
      width = scope.width
      height = width

    chart = d3.select(element[0])
      .append('svg')
      .attr("width", width)
      .attr("height", height)
      .attr("viewBox", "0 0 " + width + " " + height)
      .attr("preserveAspectRatio", "xMidYMid")
      .attr("id", scope.module.module_title)
      .append("g")
      .attr("id", "g_" + scope.module.module_title)
      .attr("class", "module-circle__points")
      .attr("transform", "translate(" + ((width/2)) + "," + ((height/2)) + ")")

    radius = Math.min(width, height) / 2

    scope.render = (module) ->
      chart.selectAll("g").remove()
      chart.selectAll("text").remove()
      # Throw in a switch statement for now, try to integrate  module
      # color directive
      switch (module.module_title)
        when 'Academics'
          moduleColor = '#41e6b2'
          moduleColorBg = '#172924'
        when 'Service'
          moduleColor = '#e8be28'
          moduleColorBg = '#2a271b'
        when 'Extracurricular'
          moduleColor = '#ef6629'
          moduleColorBg = '#291b16'
        when 'College_Prep'
          moduleColor = '#27aae1'
          moduleColorBg = '#142229'
        when 'Testing'
          moduleColor = '#9665aa'
          moduleColorBg = '#221b2a'
        # ONEGOAL_HACK START
        when '2-year'
          moduleColor = '#41e6b2'
          moduleColorBg = '#172924'
        when '4-year'
          moduleColor = '#e8be28'
          moduleColorBg = '#2a271b'
        when 'Assignments'
          moduleColor = '#ef6629'
          moduleColorBg = '#291b16'
        when 'Financial'
          moduleColor = '#27aae1'
          moduleColorBg = '#142229'
        when 'Campus_Connections'
          moduleColor = '#9665aa'
          moduleColorBg = '#221b2a'
        # ONEGOAL_HACK END

      modulePoints = module.points.user
      totalPoints = module.points.total

      if totalPoints == 0
        module_value = 1
        remaining_value = 0
      else
        module_value = modulePoints
        remaining_value = totalPoints - modulePoints

      data = [
        {name: "Points Earned", value: module_value},
        {name: "Total Points", value: remaining_value}
      ]

      color = d3.scale.ordinal()
        .range([moduleColor, moduleColorBg])

      arc = d3.svg.arc()
        .outerRadius(radius)
        .innerRadius(radius - ((7/95) * width))

      myScale = d3.scale.linear().domain([0, 360]).range([0, 2 * Math.PI])

      pie = d3.layout.pie()
        .sort(null)
        .startAngle(myScale(0))
        .endAngle(myScale(360))
        .value((d) -> d.value )

      tweenPie = (b) ->
        i = d3.interpolate({startAngle: myScale(0), endAngle: myScale(0)}, b)
        (t) ->
          arc(i(t))

      g = chart.selectAll("path")
        .data(pie(data))
        .enter().append("g")
        .append("path").style("fill", (d,i) -> color(i) )
        .transition()
          .duration(1300)
          .attrTween("d", tweenPie)
      #  .each( (d) -> this._current = d ) # stores current angles

      d3.select("#g_" + module.module_title).append("text")
        .attr("dy", (.035 * width) + "px")
        .attr("class", "value")
        .attr("fill", "white")
        .attr("font-size", (.177 * width))
        .style("text-anchor", "middle")
        .text( (d) ->
          modulePoints + "/" + totalPoints
        )

      d3.select("#g_" + module.module_title).append("text")
        .attr("dy", (.145 * width) + "px")
        .attr("class", "text")
        .attr("fill", "white")
        .attr("font-size", (.0824 * width))
        .style("text-anchor", "middle")
        .text( (d) ->
          "points"
        )

    scope.$watch('module', () ->
      scope.render(scope.module)
    , true)

    chartSelect = $("#" + scope.module.module_title)

    resizeParent = () ->
      if scope.parentclass
        onChangeWidth = $('.' + scope.parentclass).outerWidth()

        chartSelect.attr("width", onChangeWidth)
        chartSelect.attr("height", onChangeWidth)


    $(window).resize (event) -> resizeParent()

]
