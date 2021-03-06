angular.module('myApp')
.service 'UsersService', ['$http', 'CONSTANTS', ($http, CONSTANTS) ->

  @getUserWithContacts = (userId) ->
    $http.get "/api/v1/users/#{userId}/user_with_contacts"

  @getUser = (userId) ->
    $http.get "/api/v1/users/#{userId}"

  @addUser = (user) ->
    $http.post '/api/v1/users', { user: user }

  @delete = (user_id) ->
    $http.delete  "/api/v1/users/#{user_id}"

  @updateUserInfoWithPicture = (user, formData) ->
    formData.append("user[email]", user.email)
    formData.append("user[first_name]", user.first_name)
    formData.append("user[last_name]", user.last_name)
    formData.append("user[phone]", user.phone)
    formData.append("user[class_of]", user.class_of)
    formData.append("user[time_unit_id]", user.time_unit_id)
    formData.append("user[title]", user.title)

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

  # Authenticated
  @resetUserPassword = (org_id, user_ids) ->
    $http.put "/api/v1/organization/#{org_id}/users/reset_users_password", {user_ids: user_ids}

  # Unauthenticated - only use this for login page
  @resetPassword = (user) ->
    $http.post '/api/v1/users/password', user: user

  @getAssignedStudents = (userId) ->
    $http.get "/api/v1/users/#{userId}/relationship/students"

  @getAssignedStudentsForGroup = (userIds) ->
    $http.get "/api/v1/relationship/assigned_students_for_group",
      {
        params: {'user_ids[]': userIds}
      }

  @getAssignedMentors = (userId) ->
    $http.get "/api/v1/users/#{userId}/relationship/mentors"

  @assign = (mentorId, studentId) ->
    $http.post "/api/v1/users/#{mentorId}/relationship/#{studentId}"

  @unassign = (mentorId, studentId) ->
    $http.delete "/api/v1/users/#{mentorId}/relationship/#{studentId}"

  @saveParentGuardianContact = (contact) ->
    if contact.id
      $http.put "api/v1/parent_guardian_contact/#{contact.id}", parent_guardian_contact: contact
    else
      $http.post "api/v1/users/#{contact.user_id}/parent_guardian_contact", parent_guardian_contact: contact

  @deleteParentGuardianContact = (contact) ->
    $http.delete "api/v1/parent_guardian_contact/#{contact.id}"

  @newOrgAdmin = (orgId) ->
    email: ""
    first_name: ""
    last_name: ""
    phone: ""
    role: CONSTANTS.USER_ROLES.org_admin
    organization_id: orgId
    is_org_admin: true
    status: 0

  @newMentor = (orgId) ->
    email: ""
    title: ""
    first_name: ""
    last_name: ""
    phone: ""
    role: CONSTANTS.USER_ROLES.mentor
    organization_id: orgId
    is_mentor: true
    status: 0

  @newStudent = (orgId) ->
    email: ""
    first_name: ""
    last_name: ""
    phone: ""
    role: CONSTANTS.USER_ROLES.student
    organization_id: orgId
    class_of: 0
    is_student: true
    status: 0

  @newParentGuardianContact = (userId) ->
    id: null
    user_id: userId
    name: ""
    relationship: ""
    email: ""
    phone: ""

  @determineEarnedMilestones = (orgMilestones, userMilestones) ->
    for um in userMilestones
      om = _.find(orgMilestones, (om) -> om.id == um.milestone_id)
      if om
        om.earned = true
      else
        console.log("Error: user_milestone has no matching org_milestone.", um, orgMilestones)
    return orgMilestones

  @
]
