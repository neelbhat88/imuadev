angular.module('myApp')
.controller 'ServiceProgressController', ['$scope', 'UserServiceActivityService', 'ProgressService',
  ($scope, UserServiceActivityService, ProgressService) ->
    $scope.user_service_activities = []
    $scope.user_service_activity_events = []

    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        UserServiceActivityService.all($scope.student.id, $scope.selected_semester.id)
          .success (data) ->
            console.log(data.user_service_activities)
            $scope.user_service_activities = data.user_service_activities
            $scope.user_service_activity_events = data.user_service_activity_events
            $scope.$emit('loaded_module_milestones');
    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        $scope.$emit('loaded_module_milestones');
]
