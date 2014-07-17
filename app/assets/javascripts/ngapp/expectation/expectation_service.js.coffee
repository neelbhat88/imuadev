angular.module('myApp')
.service 'ExpectationService', ['$http', ($http) ->

  #####################################
  ########### ORGANIZATION ############
  #####################################

  @getExpectations = (orgId) ->
    $http.get "/api/v1/organization/#{orgId}/expectations"

  @saveExpectation = (expectation) ->
    if expectation.id
      $http.post "/api/v1/expectation/#{expectation.id}", {expectation: expectation}
    else
      $http.post "/api/v1/expectation", {expectation: expectation}

  @deleteExpectaion = (expectation) ->
    $http.delete "/api/v1/expectation/#{expectation.id}"

  #################################
  ############# USER ##############
  #################################

  @getUserExpectations = (user) ->
    $http.get "/api/v1/users/#{user.id}/expectations"

  @saveUserExpectation = (user_expectation) ->
    if user_expectation.id
      $http.post "/api/v1/user_expectation/#{user_expectation.id}", {userExpectation: user_expectation}
    else
      $http.post "/api/v1/user_expectation", {userExpectation: user_expectation}

  @deleteUserExpectation = (user_expectation) ->
    $http.delete "/api/v1/user_expectation/#{user_expectation.id}"

  @
]
