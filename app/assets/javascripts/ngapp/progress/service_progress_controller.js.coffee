angular.module('myApp')
.controller 'ServiceProgressController', ['$scope', 'UserServiceOrgsHoursService', 'ProgressService',
  ($scope, UserServiceOrgsHoursService, ProgressService) ->
    $scope.user_service_orgs = []
    $scope.user_service_hours = []

    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        UserServiceOrgsHoursService.all($scope.student.id, $scope.selected_semester.id)
          .success (data) ->
            console.log(data.user_service_orgs)
            $scope.user_service_orgs = data.user_service_orgs
            $scope.user_service_hours = data.user_service_hours
            $scope.$emit('loaded_module_milestones');
    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        $scope.$emit('loaded_module_milestones');
]
