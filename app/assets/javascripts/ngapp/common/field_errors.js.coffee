angular.module('myApp')
.directive 'fieldErrors', [() ->
  restrict: 'E',
  scope: {
    formfield: '=',
    form: '='
  }

  templateUrl: 'common/field_errors.html'
]
