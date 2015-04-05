angular.module('myApp')
.directive 'progressCircleMilestone', [() ->
  restrict: 'E',
  scope: {
    student: '='
  }
  templateUrl: 'circles/progress_circle_milestone.html'
]
