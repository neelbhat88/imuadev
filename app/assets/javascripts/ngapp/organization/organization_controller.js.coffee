angular.module('myApp')
.controller 'OrganizationCtrl', ['$scope', '$modal', 'current_user', 'organization', 'UsersService', 'ProgressService', 'ExpectationService',
  ($scope, $modal, current_user, organization, UsersService, ProgressService, ExpectationService) ->
    $scope.current_user = current_user
    $scope.organization = organization
    $scope.groupedStudents = []
    $scope.org_milestones = {}

    $('input, textarea').placeholder()

    # Sort org_milestones by time_unit_id and module, while tallying up total points
    for time_unit, org_milestones_by_time_unit of _.groupBy($scope.organization.milestones, "time_unit_id")
      $scope.org_milestones[time_unit.toString()] = {}
      for module_title, org_milestones_by_module of _.groupBy(org_milestones_by_time_unit, "module")
        $scope.org_milestones[time_unit.toString()][module_title] = org_milestones_by_module
        $scope.org_milestones[time_unit.toString()][module_title].totalPoints = 0
        for org_milestone in $scope.org_milestones[time_unit.toString()][module_title]
          $scope.org_milestones[time_unit.toString()][module_title].totalPoints += org_milestone.points

    for student in $scope.organization.students
      # Find the student's mentors
      student.mentors = []
      for mentor_id in _.uniq(_.pluck(student.relationships, "assigned_to_id"))
        student.mentors.push(_.find($scope.organization.mentors, (mentor) -> mentor.id == mentor_id))
      # Calculate modules_progress for the student
      for module_title, user_milestones_by_module of _.groupBy(student.user_milestones, "module")
        org_milestones = $scope.org_milestones[student.time_unit_id][module_title]
        new_module_progress = { module_title: module_title, time_unit_id: student.time_unit_id,\
                                points: { user: 0, total: org_milestones.totalPoints } }
        for user_milestone in user_milestones_by_module
          if user_milestone.time_unit_id == student.time_unit_id
            new_module_progress.points.user += _.find(org_milestones, (org_milestone) ->
                                                org_milestone.id == user_milestone.milestone_id).points
        student.modules_progress.push(new_module_progress)
        # Apply module_progress to the student's mentors
        for mentor in student.mentors
          mentor_module_progress = _.find(mentor.modules_progress, (mentor_module_progress) ->
            mentor_module_progress.module_title == new_module_progress.module_title)
          if mentor_module_progress != undefined
            mentor_module_progress.points.user += new_module_progress.points.user
            mentor_module_progress.points.total += new_module_progress.points.total
          else
            new_mentor_module_progress = { module_title: module_title, time_unit_id: null,\
                                           points: { user: new_module_progress.points.user,\
                                                     total: new_module_progress.points.total } }
            mentor.modules_progress.push(new_mentor_module_progress)

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
