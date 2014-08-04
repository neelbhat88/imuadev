angular.module('myApp').config ['$routeProvider', '$httpProvider', 'CONSTANTS',
($routeProvider, $httpProvider, CONSTANTS) ->
  $routeProvider.when '/',
    templateUrl: 'dashboard/dashboard.html',
    controller: 'DashboardController',
    resolve:
      current_user: ['SessionService', (SessionService) ->
        SessionService.getCurrentUser();
      ]

      user: () -> null

  .otherwise
    redirectTo: '/'
]


angular.module('myApp')
.controller "ExampleController", ["$scope", ($scope) ->
  $scope.greeting = "Hello World"

  $scope.sayGreeting = () ->
    $scope.greeting + "! This works!"
]
