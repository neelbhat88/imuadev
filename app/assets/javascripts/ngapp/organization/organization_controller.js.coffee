angular.module('myApp')
.controller 'OrganizationCtrl', ['$scope', '$modal', 'current_user', 'organization', 'UsersService', 'ProgressService',
  ($scope, $modal, current_user, organization, UsersService, ProgressService) ->
    $scope.current_user = current_user
    $scope.organization = organization
    $scope.mentors = []
    $scope.students = []

    $('input, textarea').placeholder()

    for mentor in $scope.organization.mentors
      UsersService.getAssignedStudents(mentor.id)
        .success (data) ->
          $scope.mentors.push({user: mentor, assigned_students: data.students, modules_progress: []})

    for student in $scope.organization.students
      ProgressService.getAllModulesProgress(student, student.time_unit_id).then (student_with_modules_progress) ->
        $scope.students.unshift(student_with_modules_progress)
        # Tally up mentor progress - this is pretty gross
        for mentor in $scope.mentors
          for assigned_student in mentor.assigned_students
            if assigned_student.id == student_with_modules_progress.user.id
              for student_module_progress in student_with_modules_progress.modules_progress
                found_existing_mentor_module = false
                for mentor_module_progress in mentor.modules_progress
                  if mentor_module_progress.module_title == student_module_progress.module_title
                    mentor_module_progress.points.user += student_module_progress.points.user
                    mentor_module_progress.points.total += student_module_progress.points.total
                    found_existing_mentor_module = true
                    break
                if !found_existing_mentor_module
                  new_mentor_module_progress = { module_title: student_module_progress.module_title,\
                                                 time_unit_id: null,\
                                                 points: { user:  student_module_progress.points.user,\
                                                           total: student_module_progress.points.total } }
                  mentor.modules_progress.push(new_mentor_module_progress)
              break

    $scope.loaded_users = true

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
