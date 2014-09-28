angular.module('myApp')
.config ['$routeProvider', ($routeProvider) ->
    $routeProvider.when '/setup/:id',
      templateUrl: 'setup/setup.html',
      controller: 'SetupController',
      resolve:
        current_user: ['SessionService', (SessionService) ->
          SessionService.getCurrentUser()
        ]
]
