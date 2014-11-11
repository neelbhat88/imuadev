angular.module('myApp')
.service 'ExpectationService', ['$http', ($http) ->

  # Bulk set multiple user_expectations.
  # 'assignees' is as an array of {user: user, status: status} hashes, which gets mapped
  # into an array of {user_expectation_id: user_expectation.id, status: status} hashes.
  # 'comment' is the comment to be applied to each user's user_expectation update.
  @saveExpectationStatus = (expectationId, assignees, comment) ->
    refined_assignees = _.map(assignees, (a) -> { user_expectation_id: a.user.user_expectations[0].id, status: a.status })
    $http.put "api/v1/expectation/#{expectationId}/status",
      { assignees: refined_assignees, comment: comment }

  @getExpectationStatus = (expectationId) ->
    $http.get "api/v1/expectation/#{expectationId}/status"

  #####################################
  ########### ORGANIZATION ############
  #####################################

  @newExpectation = (orgId) ->
    organization_id: orgId,
    title:           "",
    description:     "",
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
