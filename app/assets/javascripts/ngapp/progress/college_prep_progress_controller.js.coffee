angular.module('myApp')
.controller 'CollegePrepProgressController', ['$scope', 'ProgressService',
  ($scope, ProgressService) ->
    $scope.$emit('loaded_module_milestones');
]
