angular.module('myApp')
.controller 'TestingProgressController', ['$scope', 'TestService', 'ProgressService',
  ($scope, TestService, ProgressService) ->
    $scope.userTests = []
    $scope.orgTests = []


    # Note: orgTests are reloaded on semester switch
    $scope.$watch 'selected_semester', () ->
      $scope.numUserTests = 0
      if $scope.selected_semester
        TestService.getOrgTests($scope.student.organization_id)
          .success (data) ->
            $scope.orgTests = data.orgTests
            TestService.getUserTests($scope.student.id, $scope.selected_semester.id)
              .success (data) ->
                $scope.userTests = data.userTests
                $scope.numUserTests = $scope.userTests.length
                for ut in $scope.userTests
                  for ot in $scope.orgTests
                    if ot.id == ut.org_test_id
                      ut.orgTest = ot
                      break
                $scope.$emit('loaded_module_milestones');

    $scope.editUserTest = (index) ->
      $scope.userTests.editing = true
      $scope.userTests[index].editing = true
      $scope.userTests[index].new_orgTest = $scope.userTests[index].orgTest;
      $scope.userTests[index].new_date = $scope.userTests[index].date;
      $scope.userTests[index].new_score = $scope.userTests[index].score;

    $scope.cancelEditUserTest = (index) ->
      if $scope.userTests[index].id
        $scope.userTests[index].editing = false
      else
        $scope.userTests.splice(index, 1)
      $scope.userTests.editing = false;

    $scope.saveUserTest = (index) ->
      new_userTest = TestService.newUserTest($scope.userTests[index].user_id, $scope.userTests[index].time_unit_id)
      new_userTest.id = $scope.userTests[index].id
      new_userTest.org_test_id = $scope.userTests[index].new_orgTest.id
      new_userTest.date = $scope.userTests[index].new_date
      new_userTest.score = $scope.userTests[index].new_score

      TestService.saveUserTest(new_userTest)
        .success (data) ->
          $scope.userTests[index] = data.userTest
          $scope.numUserTests = $scope.userTests.length
          for ot in $scope.orgTests
            if ot.id == $scope.userTests[index].org_test_id
              $scope.userTests[index].orgTest = ot
              break
          $scope.userTests[index].editing = false
          $scope.userTests.editing = false
          $scope.refreshPoints()
          $scope.$emit('just_updated', 'Testing')

    $scope.deleteUserTest = (index) ->
      if window.confirm "Are you sure you want to delete this test?"
        TestService.deleteUserTest($scope.userTests[index])
          .success (data) ->
            $scope.userTests.splice(index, 1)
            $scope.numUserTests = $scope.userTests.length
            $scope.refreshPoints()
            $scope.$emit('just_updated', 'Testing')

    $scope.addUserTest = () ->
      $scope.userTests.editing = true
      $scope.testsEditor = false
      blank_userTest = TestService.newUserTest($scope.student.id, $scope.selected_semester.id)
      blank_userTest.new_orgTest = null
      blank_userTest.editing = true
      $scope.userTests.push(blank_userTest)
]
