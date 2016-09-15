angular.module('myApp')
.config ['$routeProvider', 'CONSTANTS', ($routeProvider, CONSTANTS) ->

  $routeProvider.when '/sa/me/caroline/:num?',
    templateUrl: 'superadmin/me/caroline.html'
    controller: 'SuperAdminCarolineCtrl'
    data:
      authorizedRoles: [CONSTANTS.USER_ROLES.super_admin]

  $routeProvider.when '/sa/organizations',
    templateUrl: 'superadmin/organizations.html'
    controller: 'SuperAdminOrganizationsCtrl'
    data:
      authorizedRoles: [CONSTANTS.USER_ROLES.super_admin]
]
