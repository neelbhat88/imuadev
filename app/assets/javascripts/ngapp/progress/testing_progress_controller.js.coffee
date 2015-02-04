angular.module('myApp')
.controller 'TestingProgressController', ['$scope', 'TestService', 'ProgressService',
  ($scope, TestService, ProgressService) ->
    $scope.userTests = []
    $scope.orgTests = []
    $scope.testErrors = []
    $scope.testsEditor = false
    $scope.formErrors = [ '**Please fix the errors above**' ]


    # Note: orgTests are reloaded on semester switch
    $scope.$watch 'selected_semester', () ->
      $scope.numUserTests = 0
      $scope.testsEditor = false
      if $scope.selected_semester
        $scope.loaded_data = false
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
                $scope.loaded_data = true
                $scope.$emit('loaded_module_milestones');

    $scope.editorClick = () ->
      $scope.testsEditor = !$scope.testsEditor

    $scope.editUserTest = (user_test) ->
      $scope.userTests.editing = true
      user_test.editing = true
      user_test.new_orgTest = user_test.orgTest;
      user_test.new_date = user_test.date;
      user_test.new_score = user_test.score;

    $scope.cancelEditUserTest = (user_test) ->
      if user_test.id
        user_test.editing = false
      else
        $scope.userTests = removeTest($scope.userTests, user_test)

      $scope.testErrors = []
      $scope.userTests.editing = false;

    removeTest = (tests, test_to_remove) ->
      _.without(tests, _.findWhere(tests, {id: test_to_remove.id}))

    $scope.saveUserTest = (user_test) ->
      new_userTest = TestService.newUserTest(user_test.user_id, user_test.time_unit_id)
      new_userTest.id = user_test.id
      new_userTest.org_test_id = user_test.new_orgTest.id
      new_userTest.date = user_test.new_date
      new_userTest.score = user_test.new_score

      TestService.saveUserTest(new_userTest)
        .success (data) ->
          user_test.editing = false
          $scope.userTests.editing = false
          user_test.id = data.userTest.id
          user_test.user_id = data.userTest.user_id
          user_test.org_test_id = data.userTest.org_test_id
          user_test.time_unit_id = data.userTest.time_unit_id
          user_test.date = data.userTest.date
          user_test.score = data.userTest.score
          $scope.numUserTests = $scope.userTests.length
          for ot in $scope.orgTests
            if ot.id == user_test.org_test_id
              user_test.orgTest = ot
              break
          $scope.refreshPoints()
          $scope.$emit('just_updated', 'Testing')
          $scope.addSuccessMessage("Test saved successfully")

    $scope.deleteUserTest = (user_test) ->
      if window.confirm "Are you sure you want to delete this test?"
        TestService.deleteUserTest(user_test)
          .success (data) ->
            $scope.userTests = removeTest($scope.userTests, user_test)
            $scope.numUserTests = $scope.userTests.length
            $scope.refreshPoints()
            $scope.$emit('just_updated', 'Testing')
            $scope.addSuccessMessage("Test deleted successfully")

    $scope.addUserTest = () ->
      $scope.userTests.editing = true
      blank_userTest = TestService.newUserTest($scope.student.id, $scope.selected_semester.id)
      blank_userTest.new_orgTest = null
      blank_userTest.editing = true
      $scope.userTests.push(blank_userTest)
]
