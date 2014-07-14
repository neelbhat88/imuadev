angular.module('myApp')
.controller 'TestingProgressController', ['$scope', 'ProgressService',
  ($scope, ProgressService) ->
    $scope.$emit('loaded_module_milestones');
]
