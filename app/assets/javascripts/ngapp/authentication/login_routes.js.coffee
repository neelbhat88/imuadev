angular.module('myApp')
.config ['$routeProvider', ($routeProvider) ->
  $routeProvider.when '/login',
    templateUrl: 'authentication/login.html',
    controller: 'LoginController'
]
