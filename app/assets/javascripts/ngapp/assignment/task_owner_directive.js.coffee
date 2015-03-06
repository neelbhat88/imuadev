angular.module('myApp')
.directive "taskOwnerDisplay", [() ->
  restrict: 'E',
  scope: {
    assignment: '='
  }
  link: (scope, elem, attrs) ->

  templateUrl: 'assignment/widgets/task_owner_display.html'

]
