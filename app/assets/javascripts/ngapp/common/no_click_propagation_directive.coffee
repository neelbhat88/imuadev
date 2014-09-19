angular.module('myApp')
.directive 'noClickPropagation', [() ->
  restrict: 'A',
  link: (scope, elem, attrs) ->
    elem.on('click', (event) ->
      event.stopPropagation()
    )
]
