angular.module('myApp')
.controller 'OrganizationCtrl', ['$q', '$scope', '$modal', 'current_user', 'organization', 'UsersService', 'ProgressService',
  ($q, $scope, $modal, current_user, organization, UsersService, ProgressService) ->
    $scope.current_user = current_user
    $scope.organization = organization
    $scope.students = []

    $('input, textarea').placeholder()

    getModulesProgress = (student) ->
      defer = $q.defer()
      ProgressService.getModules(student, student.time_unit_id)
        .success (data) ->
          defer.resolve({user: student, modules_progress: data.modules_progress})
      defer.promise

    for student in $scope.organization.students
      getModulesProgress(student).then (student_with_modules_progress) ->
        $scope.students.unshift(student_with_modules_progress)

    $scope.fullName = (user) ->
      if user.id == current_user.id
        "Me"
      else
        user.first_name + " " + user.last_name

    $scope.addOrgAdmin = () ->
      modalInstance = $modal.open
        templateUrl: 'organization/add_user_modal.html',
        controller: 'AddUserModalController',
        backdrop: 'static',
        size: 'sm',
        resolve:
          organization: () -> $scope.organization
          new_user: () -> UsersService.newOrgAdmin($scope.organization.id)

      modalInstance.result.then (user) ->
        $scope.organization.orgAdmins.push(user)

    $scope.addStudent = () ->
      modalInstance = $modal.open
        templateUrl: 'organization/add_user_modal.html',
        controller: 'AddUserModalController',
        backdrop: 'static',
        size: 'sm',
        resolve:
          organization: () -> $scope.organization
          new_user: () -> UsersService.newStudent($scope.organization.id)

      modalInstance.result.then (user) ->
        $scope.organization.students.push(user)

    $scope.addMentor = () ->
      modalInstance = $modal.open
        templateUrl: 'organization/add_user_modal.html',
        controller: 'AddUserModalController',
        backdrop: 'static',
        size: 'sm',
        resolve:
          organization: () -> $scope.organization
          new_user: () -> UsersService.newMentor($scope.organization.id)

      modalInstance.result.then (user) ->
        $scope.organization.mentors.push(user)

]
