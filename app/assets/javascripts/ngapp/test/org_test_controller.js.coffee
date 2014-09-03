angular.module('myApp')
.controller 'OrgTestController', ['$route', '$scope', 'TestService',
  ($route, $scope, TestService) ->

    $scope.TestScoreTypes = [
      "Percent",
      "Raw Number",
      "Letter Grade"
    ]

    $scope.user = $scope.current_user
    $scope.orgId = $route.current.params.id
    $scope.orgTests = []

    TestService.getOrgTests($scope.orgId)
      .success (data) ->
        $scope.orgTests = data.orgTests
        for e in $scope.orgTests
          e.editing = false
        $scope.orgTests.editing = false
        $scope.loaded_orgTests = true

    $scope.editOrgTest = (index) ->
      $scope.orgTests[index].editing = true
      $scope.orgTests[index].new_title = $scope.orgTests[index].title;
      $scope.orgTests[index].new_score_type = $scope.orgTests[index].score_type;

    $scope.cancelEditOrgTest = (index) ->
      if $scope.orgTests[index].id
        $scope.orgTests[index].editing = false
      else
        $scope.orgTests.splice(index, 1)
      $scope.orgTests.editing = false

    $scope.saveOrgTest = (index) ->
      new_orgTest = TestService.newOrgTest($scope.orgId)
      new_orgTest.id = $scope.orgTests[index].id
      new_orgTest.title = $scope.orgTests[index].new_title
      new_orgTest.score_type = $scope.orgTests[index].new_score_type

      if new_orgTest.id && (new_orgTest.title != $scope.orgTests[index].title || new_orgTest.score_type != $scope.orgTests[index].score_type)
        if !window.confirm "This will update the test while maintaining any corresponding test entries for each student. Ok to continue?"
          return

      TestService.saveOrgTest(new_orgTest)
        .success (data) ->
          $scope.orgTests[index] = data.orgTest
          $scope.orgTests[index].editing = false
          $scope.orgTests.editing = false

    $scope.deleteOrgTest = (index) ->
      if window.confirm "Are you sure you want to delete this test? This will remove any of the corresponding test entries for each student."
        TestService.deleteOrgTest($scope.orgTests[index])
          .success (data) ->
            $scope.orgTests.splice(index, 1)

    $scope.addOrgTest = () ->
      $scope.orgTests.editing = true
      blank_orgTest = TestService.newOrgTest($scope.orgId)
      blank_orgTest.editing = true
      $scope.orgTests.push(blank_orgTest)
]
