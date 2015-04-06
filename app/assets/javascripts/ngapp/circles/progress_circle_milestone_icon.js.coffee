angular.module('myApp')
.directive 'progressCircleMilestoneIcon', [() ->
  restrict: 'E',
  scope: {
    milestone: '='
  }
  templateUrl: 'circles/progress_circle_milestone_icon.html'
]
