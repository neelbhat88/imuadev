angular.module('myApp')
.directive "taskItemAssignor", [() ->
  restrict: 'E',
  scope: {
    assignment: '='
  }
  link: (scope, elem, attrs) ->

  templateUrl: 'assignment/widgets/task_item_assignor.html'

]
