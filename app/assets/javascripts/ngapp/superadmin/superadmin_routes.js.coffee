angular.module('myApp')
.config ['$routeProvider', 'CONSTANTS', ($routeProvider, CONSTANTS) ->
  $routeProvider.when '/sa/organizations',
    templateUrl: 'superadmin/organizations.html'
    controller: 'SuperAdminOrganizationsCtrl'
    data:
      authorizedRoles: [CONSTANTS.USER_ROLES.super_admin]
]
