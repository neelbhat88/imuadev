angular.module('myApp')
.directive 'salvattore', [() ->
  restrict: 'A'
  link: (scope, elem, attrs) ->
    salvattore.register_grid $(elem).get(0)
]
