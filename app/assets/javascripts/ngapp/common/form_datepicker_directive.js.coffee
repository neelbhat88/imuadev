angular.module('myApp')
.directive 'formDatepicker', [() ->
  restrict: 'E',
  replace: true,
  scope: {
    date: '=',
    label: '@',
    form: '='
  }
  link: (scope, elem, attrs) ->

    scope.open = (event) ->
      event.preventDefault()
      event.stopPropagation()
      scope.opened = !scope.opened

  templateUrl: 'common/form_datepicker.html'
]
