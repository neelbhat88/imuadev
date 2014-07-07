angular.module('myApp')
.config ['$routeProvider', 'CONSTANTS', ($routeProvider, CONSTANTS) ->
    $routeProvider.when '/organization/:id',
      templateUrl: 'organization/organization.html',
      controller: 'OrganizationCtrl',
      resolve:
        current_user: ['SessionService', (SessionService) ->
          SessionService.getCurrentUser()
        ],
        organization: ['$route', '$q', 'OrganizationService', ($route, $q, OrganizationService) ->
          defer = $q.defer()

          OrganizationService.getOrganization($route.current.params.id)
            .success (data) ->
              defer.resolve(data.organization)

            .error (data) ->
              defer.reject()

          defer.promise
        ]
      data:
        authorizedRoles: [CONSTANTS.USER_ROLES.super_admin, CONSTANTS.USER_ROLES.org_admin]

]
