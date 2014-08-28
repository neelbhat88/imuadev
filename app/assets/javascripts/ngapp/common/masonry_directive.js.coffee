angular.module('myApp')
.directive 'masonry', [() ->
  restrict: 'A',
  scope: {},
  link: (scope, elem, attrs) ->
    # $('.module-container').masonry({
    #   itemSelector: '.module'
    #  });
]
