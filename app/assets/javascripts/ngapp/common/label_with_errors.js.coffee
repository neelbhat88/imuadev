angular.module('myApp')
.directive 'labelWithErrors', [() ->
  restrict: 'E',
  scope: {
    formfield: '=',
    form: '=',
    label: '@'
  }

  templateUrl: 'common/label_with_errors.html'
]
