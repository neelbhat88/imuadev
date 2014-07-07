angular.module 'myApp', ['ngRoute', 'myApp.controllers',
                          'myApp.directives', 'ui.bootstrap', 'templates']

angular.module('myApp')
.controller 'AppController', ['$scope', 'CONSTANTS', ($scope, CONSTANTS) ->
  $scope.CONSTANTS = CONSTANTS
]

angular.module('myApp')
.run ['$rootScope', '$location', 'SessionService', ($rootScope, $location, SessionService) ->

  $rootScope.$on '$routeChangeStart', (event, next, current) ->
    # Always calling getCurrentUser on every change/refresh to make sure current_user is set
    SessionService.getCurrentUser()
      .then () ->
        # If no authorized roles than the route is authorized for everyone
        if next.data and next.data.authorizedRoles
          authorizedRoles = next.data.authorizedRoles

          if !SessionService.isAuthorized(authorizedRoles)
            $location.path('/')
            return false

        return true

  $rootScope.$on '$routeChangeError', (event, current, previous, rejection) ->
    $location.path('/')
    return false
]
