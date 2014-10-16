angular.module('myApp')
.service 'ExpectationService', ['$http', ($http) ->

  #####################################
  ########### ORGANIZATION ############
  #####################################

  @newExpectation = (orgId) ->
    organization_id: orgId,
    title:           "",
    description:     "temp description",
    rank:            0

  @getExpectations = (orgId) ->
    $http.get "/api/v1/organization/#{orgId}/expectations"

  @saveExpectation = (expectation) ->
    if expectation.id
      $http.put "/api/v1/organization/#{expectation.organization_id}/expectations/#{expectation.id}", {expectation: expectation}
    else
      $http.post "/api/v1/organization/#{expectation.organization_id}/expectations", {expectation: expectation}

  @deleteExpectation = (expectation) ->
    $http.delete "/api/v1/organization/#{expectation.organization_id}/expectations/#{expectation.id}"

  #################################
  ############# USER ##############
  #################################

  @getUserExpectations = (user) ->
    $http.get "/api/v1/users/#{user.id}/user_expectation"

  @getUserExpectation = (user_expectation_id) ->
    $http.get "/api/v1/user_expectation/#{user_expectation_id}"

  @updateUserExpectation = (user_expectation) ->
    $http.put "/api/v1/user_expectation/#{user_expectation.id}", {userExpectation: user_expectation}

  @getUserExpectationHistory = (user_expectation_id) ->
    $http.get "/api/v1/user_expectation/#{user_expectation_id}/history"

  @updateUserExpectationComment = (user_expectation) ->
    $http.put "/api/v1/user_expectation/#{user_expectation.id}/comment", {userExpectation: user_expectation}

  @
]
