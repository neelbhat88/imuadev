angular.module("myApp")
.service "UserServiceOrganizationService", ['$http', ($http) ->

  @all = (userId, time_unit_id) ->
    $http.get "/api/v1/users/#{userId}/service_organizations_hours?time_unit_id=#{time_unit_id}"

  @newServiceOrganization = (user) ->
    name: "",
    description: "",
    user_id: user.id,
    editing: true

  @newServiceHour = (user, time_unit_id, service_organization_id) ->
    name: "",
    user_service_organization_id: service_organization_id,
    hours: "",
    date: "",
    time_unit_id: time_unit_id,
    user_id: user.id,
    description: "",
    editing: true

  @saveServiceOrganization = (user_service_organization) ->
    if user_service_organization.id
      return $http.put "/api/v1/service_organization/#{user_service_organization.id}", {user_service_organization: user_service_organization}

  @saveNewServiceOrganization = (new_service_organization) ->
      return $http.post "/api/v1/service_organization", {user_service_organization: new_service_organization, user_service_hour: new_service_organization.hours[0]}

  @saveServiceHour = (user_service_hour) ->
    if user_service_hour.id
      return $http.put "/api/v1/service_hour/#{user_service_hour.id}", {user_service_hour: user_service_hour}
    else
      return $http.post "/api/v1/service_hour", {user_service_hour: user_service_hour}

  @deleteServiceOrganization = (user_service_organization, time_unit_id) ->
    return $http.delete "/api/v1/service_organization/#{user_service_organization.id}?time_unit_id=#{time_unit_id}"

  @deleteServiceHour = (user_service_hour) ->
    return $http.delete "/api/v1/service_hour/#{user_service_hour.id}"

  @
]
