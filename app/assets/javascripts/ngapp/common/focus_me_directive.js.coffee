angular.module('myApp')
.directive 'focusMe', [() ->
  restrict: 'A'
  scope: {
    trigger: '=focusMe'
  }
  link: (scope, elem, attrs) ->
    scope.$watch('trigger', (val) ->
      if val == true
        elem[0].focus()
        scope.trigger = false
    )
]
