angular.module 'myApp', ['ngRoute', 'myApp.controllers',
                          'myApp.directives', 'ui.bootstrap', 'templates',
                          'angulartics', 'angulartics.google.analytics', 'ngMessages',
                          'ipCookie']

angular.module('myApp')
.controller 'AppController', ['$rootScope','$scope', '$timeout', '$location', 'CONSTANTS',
($rootScope, $scope, $timeout, $location, CONSTANTS) ->
  $scope.CONSTANTS = CONSTANTS
  $scope._ = _

  $scope.alerts = []

  timeout = null

  $scope.closeAlert = (index) ->
    $scope.alerts.splice(index, 1)
    $timeout.cancel(timeout)

  $scope.addSuccessMessage = (msg) ->
    $scope.clearAlerts()
    message = { type: 'success', msg: msg}
    $scope.alerts.unshift(message)

    timeout = $timeout () ->
      $scope.clearAlerts()
    , 5000

  $scope.addErrorMessage = (msg) ->
    $scope.clearAlerts()
    message = { type: 'danger', msg: msg}
    $scope.alerts.unshift(message)

  $scope.clearAlerts = () ->
    $timeout.cancel(timeout)
    $scope.alerts = []

  $scope.go = (path) ->
    $location.path(path)

  $scope.$on "update_required", () ->
    $scope.reload_required = true

  $scope.$on "clear_alerts", () ->
    $scope.alerts = []

  $scope.$on "unauthorized", () ->
    window.location.href = "login?pu=" + $location.path()

  $scope.$on "loggedout", () ->
    window.location.href = "login"
]

angular.module('myApp')
.run ['$rootScope', '$location', 'ipCookie', 'SessionService',
($rootScope, $location, ipCookie, SessionService) ->

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
