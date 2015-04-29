angular.module('myApp')
.directive 'studentSelector', [() ->
  restrict: 'E',
  scope: {
    selectedStudents: '='
  }

  templateUrl: 'common/student_selector.html'
]
