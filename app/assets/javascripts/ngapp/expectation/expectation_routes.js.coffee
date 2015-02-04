angular.module('myApp')
.config ['$routeProvider', ($routeProvider) ->
  $routeProvider.when '/expectation/:expectation_id',
    templateUrl: 'expectation/expectation.html',
    controller: 'ExpectationController',
    resolve:
      current_user: ['SessionService', (SessionService) ->
        SessionService.getCurrentUser()
      ]

      expectation_id: ['$route', ($route) ->
        parseInt($route.current.params.expectation_id, 10)
      ]
]
