angular.module('myApp')
.config ['$routeProvider', 'CONSTANTS', ($routeProvider, CONSTANTS) ->
    $routeProvider.when '/students/:id',
      templateUrl: 'students/students.html',
      controller: 'StudentsCtrl',
      resolve:
        current_user: ['SessionService', (SessionService) ->
          SessionService.getCurrentUser()
        ]
      data:
        authorizedRoles: [CONSTANTS.USER_ROLES.super_admin, CONSTANTS.USER_ROLES.org_admin]

]
