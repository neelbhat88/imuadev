angular.module('myApp')
.directive 'widget', [() ->
  restrict: 'E'
  scope: { type: '@' }
  link: (scope, elem, attrs) ->
    loadTemplate(scope.type) ->
      $http.get('common/' + scope.type + '_widget.html', { cache: $templateCache })
        .success((templateContent) ->
          elem.replaceWith($compile(templateContent)(scope))
        )

]
