angular.module('myApp')
.service 'AppVersionInterceptor', ['$rootScope', '$q', ($rootScope, $q) ->
  _appVersion = $('meta[name=version]').attr("content");

  @request = (config) ->
    config.headers['AppVersion'] = _appVersion
    config.headers['X-API-EMAIL'] = localStorage.getItem("imua_email")
    config.headers['X-API-TOKEN'] = localStorage.getItem("imua_access_token")
    config

  @response = (response) ->
    _appVersion = response.config.headers.AppVersion
    response

  @responseError = (response) ->
    defer = $q.defer()
    if response.status == 426
      $rootScope.$broadcast("update_required")
      return defer.promise

    response
    return $q.reject(response)
  @
]
