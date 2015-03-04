angular.module('myApp')
.controller 'StudentViewController', ['$route', '$scope', 'current_user', 'student', 'GraphService', 'OrganizationService',
($route, $scope, current_user, student, GraphService, OrganizationService) ->
  $scope.current_user = current_user
  $scope.student = student

  Chart.defaults.global.responsive = true
  chart_options = {
    bezierCurve: false
  }
  ctx = $("#myChart").get(0).getContext("2d")

  OrganizationService.getTimeUnits($scope.student.organization_id)
  .success (data) ->
    $scope.time_units = data.org_time_units
    current_timeunit_index = _.findIndex($scope.time_units, {id: $scope.student.time_unit_id})
    $scope.range = $scope.time_units.splice(0, current_timeunit_index+1) #Include most recent time_unit
    range_ids = _.map( $scope.range, ((tu) -> tu.id) )

    GraphService.gpa([$scope.student.id], range_ids)
    .success (data) ->
      graph = get_labels_and_data($scope.range, data.gpas)

      graph_data = format_graph_data(graph)
      myNewChart = new Chart(ctx).Line(graph_data, chart_options);

  get_labels_and_data = (time_units, gpas) ->
    graph_format = {labels: [], data: []}
    for time_unit in time_units
      label = time_unit.name
      gpa = _.find(gpas, ((gpa)-> gpa.time_unit_id == time_unit.id)).regular_unweighted

      graph_format.labels.push label
      graph_format.data.push gpa

    if graph_format.labels.length == 1 # Only 1 semester of data
      graph_format.labels.unshift ""
      graph_format.data.unshift graph_format.data[0]

    graph_format

  format_graph_data = (graph) ->
    graph_data = {
      labels: graph.labels,
      datasets: [
          {
              label: "GPA History",
              fillColor: "rgba(65,230,178,0.2)",
              strokeColor: "rgba(65,230,178,1)",
              pointColor: "rgba(220,220,220,1)",
              pointStrokeColor: "#fff",
              pointHighlightFill: "#fff",
              pointHighlightStroke: "rgba(220,220,220,1)",
              data: graph.data
          }
      ]
    }
]
