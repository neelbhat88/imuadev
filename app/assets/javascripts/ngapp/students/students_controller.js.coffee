angular.module('myApp')
.controller 'StudentsCtrl', ['$scope', '$filter', '$modal', '$route', 'current_user', 'UsersService', 'ProgressService', 'ExpectationService', 'OrganizationService'
  ($scope, $filter, $modal, $route, current_user, UsersService, ProgressService, ExpectationService, OrganizationService) ->

    $scope.current_user = current_user
    $scope.current_organization = $scope.current_user.organization_name
    $scope.attention_students = []
    $scope.search = {}
    $scope.search.text = ''
    $scope.nameArray = []

    $('input, textarea').placeholder()

    OrganizationService.getOrganizationWithUsers($route.current.params.id)
      .success (data) ->
        $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization)
        $scope.initialStudentsArray = $scope.organization.students
        $scope.students = $scope.organization.students
        #for student in students
        #  $scope.nameArray.push(student.full_name)

        $scope.org_milestones = $scope.organization.org_milestones

        $scope.active_mentors = $scope.organization.active_mentors
        $scope.active_students = $scope.organization.active_students

        $scope.total_gpa = $scope.organization.total_gpa
        $scope.semester_gpa = $scope.organization.semester_gpa
        $scope.total_serviceHours = $scope.organization.total_serviceHours
        $scope.semester_serviceHours = $scope.organization.semester_serviceHours
        $scope.total_ecActivities = $scope.organization.total_ecActivities
        $scope.semester_ecActivities = $scope.organization.semester_ecActivities
        $scope.total_testsTaken = $scope.organization.total_testsTaken
        $scope.semester_testsTaken = $scope.organization.semester_testsTaken

        $scope.average_gpa = $scope.organization.average_gpa
        $scope.average_serviceHours = $scope.organization.average_serviceHours
        $scope.average_ecActivities = $scope.organization.average_ecActivities
        $scope.average_testsTaken = $scope.organization.average_testsTaken

        $scope.attention_students = _.where($scope.organization.students, { needs_attention: true })

        $scope.class_of_years = [2014,2015,2016,2017,2018,2019,2020]

        $scope.loaded_users = true

    $scope.tagFilter = (initialStudentsArray) ->
      studentsReturn = []
      if $scope.search.text != ''
        for student in initialStudentsArray
          tagPass = $filter('filter')(student.tag_list, $scope.search.text).length
          nameArray = [student.full_name]
          namePass = $filter('filter')(nameArray, $scope.search.text).length
          if tagPass > 0 or namePass > 0
            studentsReturn.push(student)
      else
        studentsReturn = initialStudentsArray

      $scope.students = studentsReturn

    $scope.$watch('search.text', () ->
      $scope.tagFilter($scope.initialStudentsArray)
    )

    $scope.fullName = (user) ->
      if user.id == current_user.id
        "Me"
      else
        user.first_name + " " + user.last_name

    $scope.addStudent = () ->
      modalInstance = $modal.open
        templateUrl: 'organization/add_user_modal.html',
        controller: 'AddUserModalController',
        backdrop: 'static',
        size: 'sm',
        resolve:
          current_user: () -> $scope.current_user
          organization: () -> $scope.organization
          new_user: () -> UsersService.newStudent($scope.organization.id)

      modalInstance.result.then (user) ->
        $scope.organization.students.push(user)
        $scope.initialStudentsArray = $scope.organization.students
        $scope.tagFilter($scope.initialStudentsArray)
        $scope.addSuccessMessage("Email with password has been sent to " + user.email)

]
