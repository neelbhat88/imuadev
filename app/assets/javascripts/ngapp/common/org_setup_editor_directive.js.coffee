angular.module('myApp')
.directive 'orgSetupEditor', [() ->
  restrict: 'A',
  link: (scope, elem, attrs) ->
    scope.$watch('current_user', (current_user) ->
      if current_user
        if current_user.role > scope.CONSTANTS.USER_ROLES.org_admin
          $(elem).hide()
        else
          $(elem).show()
    )
]
