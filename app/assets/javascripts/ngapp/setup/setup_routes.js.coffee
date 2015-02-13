angular.module('myApp')
.config ['$routeProvider', 'CONSTANTS', ($routeProvider, CONSTANTS) ->
    $routeProvider.when '/setup/:id',
      templateUrl: 'setup/setup.html',
      controller: 'SetupController',
      reloadOnSearch: false,
      resolve:
        current_user: ['SessionService', (SessionService) ->
          SessionService.getCurrentUser()
        ]
      data:
        authorizedRoles: [CONSTANTS.USER_ROLES.super_admin, CONSTANTS.USER_ROLES.org_admin, CONSTANTS.USER_ROLES.mentor]
]
