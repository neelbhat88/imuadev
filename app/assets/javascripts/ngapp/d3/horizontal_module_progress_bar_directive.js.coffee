angular.module('myApp')
.directive 'horizontalModuleProgressBar', [() ->
  restrict: 'EA'
  scope: {
    module: '=',
    width: '=',
    height: '=',
    parentclass: '@',
    identifier: '@'
  }
  link: (scope, element, attrs) ->
    if scope.parentclass
      w = $('.' + scope.parentclass).outerWidth()
      h = $('.' + scope.parentclass).outerHeight()
    else
      w = scope.width
      h = scope.height

    # Create SVG element
    svg = d3.select(element[0])
      .append("svg")
      .attr("width", w)
      .attr("height", h)
      .attr("viewBox", "0 0 " + w + " " + h)
      .attr("preserveAspectRatio", "xMidYMin")
      .attr("id", 'bar_' + scope.module.module_title)
      .append("g")

    scope.render = (module) ->
      svg.selectAll("g").remove()

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

      progressData = [
        [{ x: 0, y: module_value}],
        [{ x: 0, y: remaining_value}]
      ]

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
        .range([moduleColor, moduleColorBg])

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
          .attr("height", h)
          .attr("width", (d) ->
            xScale(d.y)
          )

    scope.$watch('module', () ->
      scope.render(scope.module)
    , true)

    chartSelect = $("#bar_"+ scope.module.module_title)

    resizeParent = () ->
      if scope.parentclass
        onChangeWidth = $('.' + scope.parentclass).outerWidth()

        chartSelect.attr("width", onChangeWidth)
        chartSelect.attr("height", onChangeWidth)


    $(window).resize (event) -> resizeParent()
]
