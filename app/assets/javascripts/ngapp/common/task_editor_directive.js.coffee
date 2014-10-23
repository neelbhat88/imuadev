angular.module('myApp')
.directive 'taskEditor', [() ->
  restrict: 'A',
  link: (scope, elem, attrs) ->
    scope.$watch('assignment', (assignment) ->
      if assignment
        if scope.current_user.id != scope.assignment.user_id &&
           !scope.current_user.is_org_admin
          $(elem).hide()
        else
          $(elem).show()
    )
]
