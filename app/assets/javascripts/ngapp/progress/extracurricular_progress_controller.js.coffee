angular.module('myApp')
.controller 'ExtracurricularProgressController', ['$scope', 'ProgressService',
  ($scope, ProgressService) ->
    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        $scope.$emit('loaded_module_milestones');
]
