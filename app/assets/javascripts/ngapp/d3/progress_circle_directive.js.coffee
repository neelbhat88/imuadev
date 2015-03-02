angular.module('myApp')
.directive 'progressCircle', ['$timeout', ($timeout) ->
  restrict: 'EA'
  scope: {
    student: '=',
    width: '=',
    parentclass: '@',
    identifier: '@',
    drawduration: '@'
  }
  link: (scope, element, attrs) ->
    $timeout( () ->
      if scope.parentclass
        width = $('.' + scope.parentclass).outerWidth()
        height = width
      else
        width = scope.width
        height = width

      if scope.drawduration?
        drawDuration = parseInt(scope.drawduration)
      else
        drawDuration = 800

      chart = d3.select(element[0])
        .attr("id", scope.student.id + "_" + scope.identifier)
        .append('svg')
        .attr("width", width)
        .attr("height", height)
        .attr("viewBox", "0 0 " + width + " " + height)
        .attr("preserveAspectRatio", "xMidYMid")
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

        data[0] = {name: "Academics", value: 0}
        data[1] = {name: "Service", value: 0}
        data[2] = {name: "Extracurricular", value: 0}
        data[3] = {name: "College_Prep", value: 0}
        data[4] = {name: "Testing", value: 0}

        for module in student.modules_progress
          user_points += module.points.user
          total_points += module.points.total
          switch module.module_title
            when "Academics" then index = 0
            when "Service" then index = 1
            when "Extracurricular" then index = 2
            when "College_Prep" then index = 3
            when "Testing" then index = 4
            # ONEGOAL_HACK START
            when '2-year' then index = 0
            when '4-year' then index = 1
            when 'Assignments' then index = 2
            when 'Financial' then index = 3
            when 'Campus_Connections' then index = 4
            # ONEGOAL_HACK END

          data[index] = {name: module.module_title, value: module.points.user}

        if total_points == 0
          progress_to_make = 1
        else
          progress_to_make = total_points - user_points

        data[5] = {name: "Future Progress", value: progress_to_make}

        arc = d3.svg.arc()
          .outerRadius(radius)
          .innerRadius(radius - ((7/95) * width))

        svg = $('#' + student.id + '_' + scope.identifier + ' svg')[0]

        photoCircle = d3.select(svg)
          .append("circle")
          .attr("cx", width - (width/2))
          .attr("cy", height - (height/2))
          .attr("r", radius-((2/19) * width))
          .style("fill", "url(#photo"+student.id+"_"+scope.identifier+")")

        image = d3.select(svg)
          .append("pattern")
          .attr("id", "photo" + student.id + "_" + scope.identifier)
          .attr("x", 0)
          .attr("y", 0)
          .attr("width", 1)
          .attr("height", 1)
          .append("image")
          .attr("x", 0)
          .attr("y", 0)
          .attr("width", width - ((1/5) * width))
          .attr("height", height - ((1/5) * height))
          .attr("xlink:href", student.square_avatar_url)

        arc2 = d3.svg.arc().outerRadius(radius - ((2/11) * width))

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
            .duration(drawDuration)
            .attrTween("d", tweenPie)

      scope.$watch('student', () ->
        scope.render(scope.student)
      , true)


      chartSelect = $("#svg"+ scope.student.id + "_" + scope.identifier)

      resizeParent = () ->
        if scope.parentclass
          onChangeWidth = $('.' + scope.parentclass).outerWidth()

          chartSelect.attr("width", onChangeWidth)
          chartSelect.attr("height", onChangeWidth)

      $(window).resize (event) -> resizeParent()
    , 0
    )

]
