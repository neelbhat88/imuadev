angular.module('myApp')
.service 'AppVersionInterceptor', ['$rootScope', ($rootScope) ->
  _appVersion = $('meta[name=version]').attr("content");

  @request = (config) ->
    config.headers['AppVersion'] = _appVersion
    config

  @response = (response) ->
    _appVersion = response.config.headers.AppVersion
    response

  @responseError = (response) ->
    if response.status == 426
      $rootScope.$broadcast("update_required")
    else if response.status == 401
      $rootScope.$broadcast("session_timeout")

    response
  @
]
