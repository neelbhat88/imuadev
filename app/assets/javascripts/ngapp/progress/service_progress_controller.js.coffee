angular.module('myApp')
.controller 'ServiceProgressController', ['$scope', 'ProgressService',
  ($scope, ProgressService) ->
    $scope.$emit('loaded_module_milestones');
]
