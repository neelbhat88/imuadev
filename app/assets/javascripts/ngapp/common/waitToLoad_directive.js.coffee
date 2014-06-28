angular.module('myApp')
.directive 'waitToLoad', [() ->
  restrict: 'A',
  transclude: true,
  scope: {},
  link: (scope, elem, attrs) ->
    attrs.$observe 'waitToLoad', (value) ->
      scope.watchedObject = value

  templateUrl: 'common/loading_animation.html'
]