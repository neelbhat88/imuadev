angular.module('myApp')
.controller 'StudentViewController', ['$route', '$scope', 'current_user', 'student', 'GraphService', 'OrganizationService',
($route, $scope, current_user, student, GraphService, OrganizationService) ->
  $scope.current_user = current_user
  $scope.student = student

  Chart.defaults.global.responsive = true
  ctx = $("#myChart").get(0).getContext("2d")

  OrganizationService.getTimeUnits($scope.student.organization_id)
  .success (data) ->
    $scope.time_units = data.org_time_units
    current_timeunit_index = _.findIndex($scope.time_units, {id: $scope.student.time_unit_id})
    $scope.range = $scope.time_units.splice(0, current_timeunit_index+1) #Include most recent time_unit
    range_ids = _.map( $scope.range, ((tu) -> tu.id) )

    GraphService.gpa([$scope.student.id], range_ids)
    .success (data) ->
      console.log(data)
      graph_data = []
      for time_unit in $scope.range
        label = time_unit.name
        gpa = _.find(data.history, ((gpa)-> gpa.time_unit_id == time_unit.id)).regular_unweighted

        graph_data.push {label: label, gpa: gpa}

      labels = _.map( graph_data, ((data) -> data.label ))
      gpas = _.map( graph_data, ((data) -> data.gpa))
      data = {
        labels: labels,
        datasets: [
            {
                label: "My First dataset",
                fillColor: "rgba(65,230,178,0.2)",
                strokeColor: "rgba(65,230,178,1)",
                pointColor: "rgba(220,220,220,1)",
                pointStrokeColor: "#fff",
                pointHighlightFill: "#fff",
                pointHighlightStroke: "rgba(220,220,220,1)",
                data: gpas
            }
        ]
      }
      myNewChart = new Chart(ctx).Line(data, null);

]
