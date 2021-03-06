angular.module('myApp')
.controller 'StudentsCtrl', ['$scope', '$filter', '$location', '$modal', '$route', 'current_user', 'UsersService', 'ProgressService', 'ExpectationService', 'OrganizationService', 'ModuleService', 'TaggingService'
  ($scope, $filter, $location, $modal, $route, current_user, UsersService, ProgressService, ExpectationService, OrganizationService, ModuleService, TaggingService) ->

    $scope.current_user = current_user
    $scope.current_organization = $scope.current_user.organization_name
    $scope.attention_students = []
    $scope.search = {}
    $scope.search.text = ''
    $scope.nameArray = []
    $scope.selectedStudents = []
    $scope.classOfSelect = {}
    $scope.classOfSelect.selected = []
    $scope.selectionMode = false
    $scope.tag = {}
    $scope.orgTags = {}
    $('input, textarea').placeholder()

    OrganizationService.getOrganizationWithUsers($route.current.params.id)
      .success (data) ->
        $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization)
        for student in $scope.organization.students
          student.is_selected = false
        $scope.initialStudentsArray = $scope.organization.students
        $scope.students = $scope.organization.students

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
        # this is temporary and will eventually be parsed by class of tag
        $scope.class_of_years = [2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,2024]

        $scope.loaded_users = true

        TaggingService.getOrgTags($scope.organization.id)
          .success (data) ->
            $scope.orgTags = data.tags

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

    $scope.setSelectedClass = (is_selected) ->
      if is_selected
        'is-selected'
      else
        ''

    $scope.selectClassOf = (groupYear) ->
      if $scope.classOfSelect.selected[groupYear]
        for student in $scope.students
          unless _.findWhere($scope.selectedStudents, { id: student.id })
            if student.class_of == groupYear
              student.is_selected = true
              $scope.selectedStudents.push(student)
      else
        for student in $scope.selectedStudents
          if student.class_of == groupYear
            student.is_selected = false
        $scope.selectedStudents = _.filter($scope.selectedStudents, (student) -> student.class_of != groupYear)

    $scope.$watch('selectedStudents', () ->
      if $scope.class_of_years?
        for year in $scope.class_of_years
          if !_.findWhere($scope.selectedStudents, {class_of: year})
            $scope.classOfSelect.selected[year] = false
    )

    $scope.toggleSelectionMode = () ->
      $scope.selectionMode = !$scope.selectionMode

    $scope.removeStudentFromSelectBar = (student) ->
      if _.findWhere($scope.selectedStudents, { id: student.id })
        $scope.selectedStudents = _.without($scope.selectedStudents, _.findWhere($scope.selectedStudents, { id: student.id }))
        student.is_selected = false

    $scope.selectAll = () ->
      $scope.selectionMode = true
      for student in $scope.students
        if $scope.selectedStudents.length != 0
          if !_.findWhere($scope.selectedStudents, { id: student.id }) or $scope.selectedStudents.length == 0
            student.is_selected = true
            $scope.selectedStudents.push(student)
        else if $scope.selectedStudents.length == 0
          $scope.selectedStudents.push(student)
          student.is_selected = true
          $scope.singleStudent = $scope.selectedStudents[0]
          $scope.singleStudent.total_points = 0
          $scope.singleStudent.user_points = 0

          for mod in $scope.singleStudent.modules_progress
            $scope.singleStudent.total_points += mod.points.total
            $scope.singleStudent.user_points += mod.points.user

    $scope.studentSelect = (student) ->
      if $scope.selectionMode
        if _.findWhere($scope.selectedStudents, { id: student.id })
          $scope.selectedStudents = _.without($scope.selectedStudents, _.findWhere($scope.selectedStudents, { id: student.id }))
          student.is_selected = false
        else
          $scope.selectedStudents.push(student)
          student.is_selected = true
          $scope.singleStudent = $scope.selectedStudents[0]
          $scope.singleStudent.total_points = 0
          $scope.singleStudent.user_points = 0

          for mod in $scope.singleStudent.modules_progress
            $scope.singleStudent.total_points += mod.points.total
            $scope.singleStudent.user_points += mod.points.user
      else
        for oldStudent in $scope.selectedStudents
          oldStudent.is_selected = false
        $scope.selectedStudents = []
        $scope.selectedStudents.push(student)
        student.is_selected = true
        $scope.singleStudent = $scope.selectedStudents[0]
        $scope.singleStudent.total_points = 0
        $scope.singleStudent.user_points = 0

        for mod in $scope.singleStudent.modules_progress
          $scope.singleStudent.total_points += mod.points.total
          $scope.singleStudent.user_points += mod.points.user


    $scope.clearSelected = (selectedStudents) ->
      for student in selectedStudents
        student.is_selected = false
      $scope.tag = {}
      $scope.selectedStudents = []

    $scope.fullName = (user) ->
      if user.id == current_user.id
        "Me"
      else
        user.first_name + " " + user.last_name

    $scope.selectModule = (student, mod) ->
      ModuleService.selectModule(mod)
      $location.path('/progress/' + student.id)

    $scope.addTag = () ->
      $scope.tag.editing = true

    $scope.saveTag = () ->
      TaggingService.saveTagMultipleUsers($scope.organization.id, $scope.selectedStudents, $scope.tag.name)
        .success (data) ->
          $scope.addSuccessMessage("\"" + data.tag + "\"" + " tag has been added!")
          for student in $scope.selectedStudents
            student.tag_list.push(data.tag)
          $scope.tag.editing = false
          $scope.tag.name = ''

    $scope.cancelTag = () ->
      $scope.tag.editing = false
      $scope.tag.name = ''

    $scope.addNewTask = (selectedStudents, current_user) ->
      modalInstance = $modal.open
        templateUrl: 'students/add_task_modal.html',
        controller: 'AddTaskModalController',
        backdrop: 'static',
        size: 'lg',
        resolve:
          selectedStudents: () -> $scope.selectedStudents
          current_user: () -> $scope.current_user

      modalInstance.result.then () ->
        $scope.addSuccessMessage("Task has been created!")

    $scope.manageExpectations = (selectedStudents, current_user) ->
      modalInstance = $modal.open
        templateUrl: 'students/manage_expectation_modal.html',
        controller: 'ManageExpectationModalController',
        backdrop: 'static',
        size: 'lg',
        resolve:
          selectedStudents: () -> $scope.selectedStudents
          current_user: () -> $scope.current_user

      modalInstance.result.then () ->
        $scope.addSuccessMessage("Expectation has been modified!")

    $scope.remove_user = (user) ->
      if window.confirm "Are you sure you want to delete #{user.full_name}? **This will permananetly delete the user and ALL of
                          their associated data.**"
        UsersService.delete(user.id)
          .success (data) ->
            $scope.addSuccessMessage("User deleted successfully")
            idx = $scope._.findIndex($scope.students, ((item)-> item.id == user.id))
            $scope.students.splice(idx, 1)

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
