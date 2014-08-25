angular.module('myApp')
.controller 'ServiceProgressController', ['$scope', 'UserServiceOrganizationService', 'ProgressService',
  ($scope, UserServiceOrganizationService, ProgressService) ->
    $scope.user_service_organizations = []
    $scope.previous_organization_list = []
    $scope.semester_service_hours = 0

    $scope.$watch 'user_service_organizations', () ->
      $scope.loaded_semester_service_hours = false
      $scope.semester_service_hours = 0
      for organization in $scope.user_service_organizations
        if organization.hours
          for hour in organization.hours
            if hour.hours
              $scope.semester_service_hours += parseFloat hour.hours
      $scope.loaded_semester_service_hours = true
    , true

    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        UserServiceOrganizationService.all($scope.student.id, $scope.selected_semester.id)
          .success (data) ->
            $scope.previous_organization_list = data.user_service_organizations
            $scope.user_service_organizations = data.user_service_organizations

            for user_service_organization in $scope.user_service_organizations
              user_service_organization.hours = []
              for user_service_hour in data.user_service_hours
                if user_service_organization.id == user_service_hour.user_service_organization_id
                  user_service_organization.hours.push(user_service_hour)
            console.log($scope.user_service_organizations)

            $scope.$emit('loaded_module_milestones')

    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        $scope.$emit('loaded_module_milestones')

    $scope.saveOrganization = (index) ->
      if !!$scope.user_service_organizations[index].previous_organization
        UserServiceOrganizationService
          .saveServiceOrganization($scope.user_service_organizations[index].previous_organization)
          .success (data) ->
            $scope.user_service_organizations[index] = data.user_service_organization
            $scope.user_service_organizations[index].hours = service_hours
            $scope.user_service_organizations.editing = false
            $scope.refreshPoints()
      else
        new_service_organization = UserServiceOrganizationService.newServiceOrganization($scope.student)
        new_service_organization.id = $scope.user_service_organizations[index].id
        new_service_organization.name = $scope.user_service_organizations[index].new_name
        service_hours = $scope.user_service_organizations[index].hours

        UserServiceOrganizationService.saveServiceOrganization(new_service_organization)
          .success (data) ->
            $scope.user_service_organizations[index] = data.user_service_organization
            $scope.user_service_organizations[index].hours = service_hours
            $scope.user_service_organizations.editing = false
            $scope.refreshPoints()

    $scope.saveHour = (parentIndex, index, serviceOrganizationId) ->
      new_service_hour = UserServiceOrganizationService.newServiceHour($scope.student, $scope.selected_semester.id, serviceOrganizationId)
      new_service_hour.id = $scope.user_service_organizations[parentIndex].hours[index].id
      new_service_hour.description = $scope.user_service_organizations[parentIndex].hours[index].new_description
      new_service_hour.hours = $scope.user_service_organizations[parentIndex].hours[index].new_hours
      new_service_hour.date = $scope.user_service_organizations[parentIndex].hours[index].new_date
      $scope.user_service_organizations[parentIndex].hours.editing = false

      UserServiceOrganizationService.saveServiceHour(new_service_hour)
        .success (data) ->
          $scope.user_service_organizations[parentIndex].hours[index] = data.user_service_hour
          $scope.user_service_organizations[parentIndex].hours[index].editing = false
          $scope.refreshPoints()

    $scope.deleteOrganization = (index) ->
      if window.confirm "Are you sure you want to delete this organization?"
        UserServiceOrganizationService.deleteServiceOrganization($scope.user_service_organizations[index])
          .success (data) ->
            $scope.user_service_organizations.splice(index, 1)
            $scope.refreshPoints()

    $scope.deleteHour = (parentIndex, index) ->
      if window.confirm "Are you sure you want to delete this hour?"
        UserServiceOrganizationService.deleteServiceHour($scope.user_service_organizations[parentIndex].hours[index])
          .success (data) ->
            $scope.user_service_organizations[parentIndex].hours.splice(index, 1)
            $scope.refreshPoints()

    $scope.cancelOrganizationEdit = (index) ->
      if $scope.user_service_organizations[index].id
        $scope.user_service_organizations[index].editing = false
      else
        $scope.user_service_organizations.splice(index, 1)

      $scope.user_service_organizations.editing = false

    $scope.cancelHourEdit= (parentIndex, index) ->
      if $scope.user_service_organizations[parentIndex].hours[index].id
        $scope.user_service_organizations[parentIndex].hours[index].editing = false
      else
        $scope.user_service_organizations[parentIndex].hours.splice(index, 1)

      $scope.user_service_organizations[parentIndex].hours.editing = false

    $scope.addOrganization = () ->
      $scope.user_service_organizations.editing = true
      $scope.user_service_organizations.push(UserServiceOrganizationService.newServiceOrganization($scope.student, $scope.selected_semester.id))

    $scope.addHour= (index, user_service_organization_id) ->
      if !!$scope.user_service_organizations[index].hours
        $scope.user_service_organizations[index].hours.editing = true
        $scope.user_service_organizations[index].hours.push(UserServiceOrganizationService.newServiceHour($scope.student, $scope.selected_semester.id, user_service_organization_id))
      else
        $scope.user_service_organizations[index].hours = []
        $scope.user_service_organizations[index].hours.push(UserServiceOrganizationService.newServiceHour($scope.student, $scope.selected_semester.id, user_service_organization_id))

    $scope.editOrganization= (index) ->
      $scope.user_service_organizations[index].editing = true
      $scope.user_service_organizations[index].new_name= $scope.user_service_organizations[index].name

    $scope.editHour = (parentIndex, index) ->
      $scope.user_service_organizations[parentIndex].hours[index].editing = true
      $scope.user_service_organizations[parentIndex].hours[index].new_description = $scope.user_service_organizations[parentIndex].hours[index].description
      $scope.user_service_organizations[parentIndex].hours[index].new_hours = $scope.user_service_organizations[parentIndex].hours[index].hours
      $scope.user_service_organizations[parentIndex].hours[index].new_date= $scope.user_service_organizations[parentIndex].hours[index].date

    $scope.addNewOrganization = (index) ->
      $scope.user_service_organizations[index].newOrganization = true

    $scope.selectAction = (index) ->
      console.log($scope.user_service_organizations[index].previous_organization)

]
