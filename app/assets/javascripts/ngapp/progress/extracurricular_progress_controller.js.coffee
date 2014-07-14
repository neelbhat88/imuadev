angular.module('myApp')
.controller 'ExtracurricularProgressController', ['$scope', 'ProgressService',
  ($scope, ProgressService) ->
    $scope.$emit('loaded_module_milestones');
]
