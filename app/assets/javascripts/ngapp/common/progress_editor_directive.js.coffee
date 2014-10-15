angular.module('myApp')
.directive 'progressEditor', [() ->
  restrict: 'A',
  link: (scope, elem, attrs) ->
    scope.$watch('selected_semester', (sem) ->
      if sem
        if scope.current_user.is_student &&
           (scope.current_user.id != scope.student.id ||
            scope.current_user.time_unit_id != sem.id)
          $(elem).hide()
        else
          $(elem).show()
    )
]
