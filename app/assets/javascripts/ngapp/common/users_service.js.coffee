angular.module('myApp')
.service 'UsersService', ['$http', 'CONSTANTS', ($http, CONSTANTS) ->

  @getUserInfo = (userId) ->

  @getUser = (userId) ->
    $http.get "/api/v1/users/#{userId}"

  @addUser = (user) ->
    $http.post '/api/v1/users', { user: user }

  @updateUserInfoWithPicture = (user, formData) ->
    formData.append("user[first_name]", user.first_name)
    formData.append("user[last_name]", user.last_name)
    formData.append("user[phone]", user.phone)
    formData.append("user[class_of]", user.class_of)

    $http.put '/api/v1/users/' + user.id, formData,
      {
        transformRequest: angular.identity,
        headers: {'Content-Type': undefined}
      }

  @updateUserPassword = (user, password) ->
    user =
      id: user.id
      current_password: password.current
      password: password.new
      password_confirmation: password.confirm

    $http.put '/api/v1/users/' + user.id + '/update_password', user: user

  @getAssignedStudents = (userId) ->
    $http.get "/api/v1/users/#{userId}/relationship/students"

  @getAssignedMentors = (userId) ->
    $http.get "/api/v1/users/#{userId}/relationship/mentors"

  @assign = (mentorId, studentId) ->
    $http.post "/api/v1/users/#{mentorId}/relationship/#{studentId}"

  @unassign = (mentorId, studentId) ->
    $http.delete "/api/v1/users/#{mentorId}/relationship/#{studentId}"

  @newOrgAdmin = (orgId) ->
    email: ""
    first_name: ""
    last_name: ""
    phone: ""
    role: CONSTANTS.USER_ROLES.org_admin
    organization_id: orgId
    is_org_admin: true

  @newMentor = (orgId) ->
    email: ""
    first_name: ""
    last_name: ""
    phone: ""
    role: CONSTANTS.USER_ROLES.mentor
    organization_id: orgId
    is_mentor: true

  @newStudent = (orgId) ->
    email: ""
    first_name: ""
    last_name: ""
    phone: ""
    role: CONSTANTS.USER_ROLES.student
    organization_id: orgId
    class_of: 0
    is_student: true

  @
]
