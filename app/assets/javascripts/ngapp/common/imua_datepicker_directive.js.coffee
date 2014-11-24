angular.module('myApp')
.directive 'imuaDatepicker', [() ->
  restrict: 'E',
  scope: {
    date: '='
  }
  link: (scope, elem, attrs) ->

    scope.open = (event) ->
      event.preventDefault()
      event.stopPropagation()
      scope.opened = !scope.opened

  templateUrl: 'common/imua_datepicker.html'
]
