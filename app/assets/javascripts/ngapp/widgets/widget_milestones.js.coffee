angular.module('myApp')
.directive 'widgetMilestones', [() ->
  restrict: 'E'
  templateUrl: 'widgets/widget_milestones.html'
]
