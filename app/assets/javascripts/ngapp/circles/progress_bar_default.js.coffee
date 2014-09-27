angular.module('myApp')
.directive 'progressBarDefault', [() ->
  restrict: 'E'
  templateUrl: 'circles/progress_bar_default.html'
]
