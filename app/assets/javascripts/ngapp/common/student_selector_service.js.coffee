angular.module('myApp')
.service 'StudentSelectorService', ['$http', ($http) ->
    @toggleSelectionMode = () ->
      $scope.selectionMode = !$scope.selectionMode

    @removeStudentFromSelectBar = (student) ->
      if _.findWhere($scope.selectedStudents, { id: student.id })
        $scope.selectedStudents = _.without($scope.selectedStudents, _.findWhere($scope.selectedStudents, { id: student.id }))
        student.is_selected = false

    @selectAll = () ->
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

    @studentSelect = (student) ->
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


    @clearSelected = (selectedStudents) ->
      for student in selectedStudents
        student.is_selected = false
      $scope.tag = {}
      $scope.selectedStudents = []

  @
]
