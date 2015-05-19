angular.module('myApp')
.directive 'studentSelector', ['$location', 'ModuleService', '$modal', 'TaggingService', ($location, ModuleService, $modal, TaggingService) ->
  restrict: 'E'

  link: ($scope, element, attrs) ->
    $scope.selectedStudents = []
    $scope.tag = {}
    current_user = $scope.current_user
    $scope.selectionMode = false

    $scope.setSelectedClass = (is_selected) ->
      if is_selected
        'is-selected-photo'
      else
        ''

    $scope.toggleSelectionMode = () ->
      $scope.selectionMode = !$scope.selectionMode

    $scope.removeStudentFromSelectBar = (student) ->
      if _.findWhere($scope.selectedStudents, { id: student.id })
        $scope.selectedStudents = _.without($scope.selectedStudents, _.findWhere($scope.selectedStudents, { id: student.id }))
        student.is_selected = false

    $scope.selectGroup = (students, groupIsSelected) ->
      if groupIsSelected
        for student in students
          unless _.findWhere($scope.selectedStudents, { id: student.id })
            student.is_selected = true
            $scope.selectedStudents.push(student)
      else
        for student in students
          student.is_selected = false
          $scope.selectedStudents = _.without($scope.selectedStudents, _.findWhere($scope.selectedStudents, { id: student.id }))

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
      $scope.$emit("clearSelected")

    $scope.selectModule = (student, mod) ->
      ModuleService.selectModule(mod)
      $location.path('/progress/' + student.id)

    $scope.addTag = () ->
      $scope.tag.editing = true

    $scope.saveTag = () ->
      TaggingService.saveTagMultipleUsers($scope.current_user.organization_id, $scope.selectedStudents, $scope.tag.name)
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
          current_user: () -> current_user

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
          current_user: () -> current_user

      modalInstance.result.then () ->
        $scope.addSuccessMessage("Expectation has been modified!")


  templateUrl: 'common/student_selector.html'
]
