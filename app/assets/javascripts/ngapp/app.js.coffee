angular.module 'myApp', ['ngRoute', 'myApp.controllers',
                          'myApp.directives', 'ui.bootstrap', 'templates',
                          'angulartics', 'angulartics.google.analytics']

angular.module('myApp')
.controller 'AppController', ['$rootScope','$scope', 'CONSTANTS', ($rootScope, $scope, CONSTANTS) ->
  $scope.CONSTANTS = CONSTANTS
  $scope._ = _

  $scope.alerts = []

  $scope.closeAlert = (index) ->
    $scope.alerts.splice(index, 1)

  $scope.addSuccessMessage = (msg) ->
    message = { type: 'success', msg: msg}
    $scope.alerts.unshift(message)

  $scope.addErrorMessage = (msg) ->
    message = { type: 'danger', msg: msg}
    $scope.alerts.unshift(message)

  $scope.$on "update_required", () ->
    $scope.reload_required = true

  $scope.$on "clear_alerts", () ->
    $scope.alerts = []
]

angular.module('myApp')
.run ['$rootScope', '$location', 'SessionService', ($rootScope, $location, SessionService) ->
  $rootScope.$on '$routeChangeStart', (event, next, current) ->
    # Clear messages
    $rootScope.$broadcast("clear_alerts")

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
