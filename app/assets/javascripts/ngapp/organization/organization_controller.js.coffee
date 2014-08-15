angular.module('myApp')
.controller 'OrganizationCtrl', ['$scope', '$modal', 'current_user', 'organization', 'UsersService', 'ProgressService', 'ExpectationService',
  ($scope, $modal, current_user, organization, UsersService, ProgressService, ExpectationService) ->
    $scope.current_user = current_user
    $scope.organization = organization
    $scope.mentors = []
    $scope.groupedStudents = []
    $scope.mentor_ids = []

    $('input, textarea').placeholder()

    for mentor in $scope.organization.mentors
      mentor.assigned_student_ids = []
      mentor.modules_progress = []
      $scope.mentors.push(mentor)
      $scope.mentor_ids.push(mentor.id)

    UsersService.getAssignedStudentsForGroup($scope.mentor_ids)
      .success (data) ->
        for assigned_students_for_user in data.assigned_students_for_group
          for mentor in $scope.mentors
            if mentor.id == parseInt assigned_students_for_user.user_id
              mentor.assigned_student_ids = (id for id in assigned_students_for_user.student_ids)
              break

        for student in $scope.organization.students
          # Tally up mentor progress - this is pretty gross
          for mentor in $scope.mentors
            for assigned_student_id in mentor.assigned_student_ids
              if assigned_student_id == student.id
                for student_module_progress in student.modules_progress
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

    $scope.groupedStudents = _.groupBy($scope.organization.students, "class_of")

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
        $scope.groupedStudents = _.groupBy($scope.organization.students, "class_of")

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
        $scope.mentors.push(user)

]
