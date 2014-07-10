angular.module('myApp')
.controller 'ServiceProgressController', ['$scope', 'ProgressService',
  ($scope, ProgressService) ->

    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        ProgressService.yesNoMilestones($scope.student, $scope.selected_semester.id, $scope.selected_module.module_title)
          .success (data) ->
            $scope.yes_no_milestones = data.yes_no_milestones
            $scope.loaded_yes_no_milestones = true
]
