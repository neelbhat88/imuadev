angular.module('myApp')
.controller 'StudentViewController', ['$route', '$scope', 'current_user', 'student', 'GraphService', 'OrganizationService',
($route, $scope, current_user, student, GraphService, OrganizationService) ->
  $scope.current_user = current_user
  $scope.student = student
  $scope.semester_slider = {
    start: 0,
    end: -1 #-1 so graph is only drawn once on ititial load
  }

  Chart.defaults.global.responsive = true
  Chart.defaults.global.maintainAspectRatio = false
  Chart.defaults.global.scaleOverride = true
  Chart.defaults.global.scaleSteps = 4
  Chart.defaults.global.scaleStepWidth = 1
  Chart.defaults.global.scaleStartValue = 0

  chart_options = {
    bezierCurve: false
  }
  ctx = $("#myChart").get(0).getContext("2d")

  OrganizationService.getTimeUnits($scope.student.organization_id)
  .success (data) ->
    $scope.time_units = data.org_time_units
    current_timeunit_index = _.findIndex($scope.time_units, {id: $scope.student.time_unit_id})

    $scope.semester_slider.start = 0
    $scope.semester_slider.end = current_timeunit_index

  $scope.$watch 'semester_slider.start', (newVal, oldVal) ->
    return if newVal == oldVal

    start = newVal
    end = $scope.semester_slider.end
    _drawGpaGraph(start, end)

  $scope.$watch 'semester_slider.end', (newVal, oldVal) ->
    return if newVal == oldVal

    start = $scope.semester_slider.start
    end = newVal
    _drawGpaGraph(start, end)

  _drawGpaGraph = (start_index, end_index) ->
    return if !$scope.time_units

    range = $scope.time_units.slice(start_index, end_index+1)
    range_ids = _.map( range, ((tu) -> tu.id) )
    GraphService.gpa([$scope.student.id], range_ids)
    .success (data) ->
      graph_data = _getLabelsAndData(range, data.gpas)

      graph = _formatGraph(graph_data)
      $scope.myNewChart.destroy() if $scope.myNewChart
      $scope.myNewChart = new Chart(ctx).Line(graph, chart_options)

  _getLabelsAndData = (time_units, gpas) ->
    graph_format = {labels: [], data: []}
    for time_unit in time_units
      label = time_unit.name
      gpa = _.find(gpas, ((gpa)-> gpa.time_unit_id == time_unit.id)).regular_unweighted

      graph_format.labels.push label
      graph_format.data.push gpa

    if graph_format.labels.length == 1 # Only 1 semester of data
      graph_format.labels.unshift graph_format.labels[0]
      graph_format.data.unshift graph_format.data[0]

    graph_format

  _formatGraph = (data) ->
    graph_data = {
      labels: data.labels,
      datasets: [
          {
              label: "GPA History",
              fillColor: "rgba(65,230,178,0.2)",
              strokeColor: "rgba(65,230,178,1)",
              pointColor: "rgba(220,220,220,1)",
              pointStrokeColor: "#fff",
              pointHighlightFill: "#fff",
              pointHighlightStroke: "rgba(220,220,220,1)",
              data: data.data
          }
      ]
    }
]
