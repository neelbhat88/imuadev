angular.module('myApp')
.controller 'PDUProgressController', ['$scope', 'ProgressService',
  ($scope, ProgressService) ->

    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        ProgressService.yesNoMilestones($scope.current_user, $scope.selected_semester.id, $scope.selected_module.module_title)
          .success (data) ->
            $scope.yes_no_milestones = data.yes_no_milestones
]
