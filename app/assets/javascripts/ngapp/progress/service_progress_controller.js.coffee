angular.module('myApp')
.controller 'ServiceProgressController', ['$scope', 'ProgressService',
  ($scope, ProgressService) ->
    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        $scope.$emit('loaded_module_milestones');
]
