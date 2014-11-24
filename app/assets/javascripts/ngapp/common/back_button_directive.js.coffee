angular.module('myApp')
.directive "backButton", ["$window", ($window) ->
  restrict: 'A'
  link: (scope, elem, attrs) ->
    $(elem).on 'click', () ->
      $window.history.back()

]
