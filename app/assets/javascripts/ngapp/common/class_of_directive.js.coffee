angular.module('myApp')
.directive 'classOfDropdown', [() ->
  restrict: 'E'
  scope: {
    model: '='
  }
  link: (scope, elem, attrs) ->

  templateUrl: 'common/class_of_dd.html'
]
