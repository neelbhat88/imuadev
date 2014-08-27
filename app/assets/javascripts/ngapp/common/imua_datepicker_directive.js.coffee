angular.module('myApp')
.directive 'imuaDatepicker', [() ->
  restrict: 'E'
  scope: {
    date: '='
    isModal: '&isModal'
  }
  link: (scope, elem, attrs) ->

    scope.append_to_body = !(attrs.isModal == "true")

    scope.open = (event) ->
      event.preventDefault()
      event.stopPropagation()
      scope.opened = !scope.opened

  templateUrl: 'common/imua_datepicker.html'
]
