angular.module('myApp')
.directive 'progressCircleMilestone', [() ->
  restrict: 'E',
  scope: {
    user: '='
  }
  templateUrl: 'circles/progress_circle_milestone.html'
  link: pre: (scope, elem, attr) ->
    scope.student = scope.user.student_with_modules_progress
]
