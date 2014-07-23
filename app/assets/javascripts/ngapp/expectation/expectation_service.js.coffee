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

  @newUserExpectation = (userId, expectationId, status) ->
    user_id:        userId,
    expectation_id: expectationId,
    status:         status

  @getUserExpectations = (user) ->
    $http.get "/api/v1/users/#{user.id}/expectations"

  @saveUserExpectation = (user_expectation) ->
    if user_expectation.id
      $http.put "/api/v1/users/#{user_expectation.user_id}/expectations/#{user_expectation.expectation_id}", {userExpectation: user_expectation}
    else
      $http.post "/api/v1/users/#{user_expectation.user_id}/expectations/#{user_expectation.expectation_id}", {userExpectation: user_expectation}

  @deleteUserExpectation = (user_expectation) ->
    $http.delete "/api/v1/users/#{user_expectation.user_id}/expectations/#{user_expectation.expectation_id}"

  @
]
