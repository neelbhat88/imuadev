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
            $scope.user_service_organizations = []
            $scope.previous_organization_list = []
            current_user_service_organizations = data.user_service_organizations

            for user_service_organization in current_user_service_organizations
              user_service_organization.hours = []
              for user_service_hour in data.user_service_hours
                if user_service_organization.id == user_service_hour.user_service_organization_id and
                user_service_hour.time_unit_id == $scope.selected_semester.id
                  user_service_organization.hours.push(user_service_hour)

            for user_service_organization in current_user_service_organizations
              if user_service_organization.hours.length > 0
                $scope.user_service_organizations.push(user_service_organization)
              else
                $scope.previous_organization_list.push(user_service_organization)

            $scope.$emit('loaded_module_milestones')

    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        $scope.$emit('loaded_module_milestones')

    $scope.saveOrganization = (index) ->
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

    $scope.saveNewOrganization = () ->
      if $scope.new_service_organization.hours[0].user_service_organization_id
        UserServiceOrganizationService.saveServiceHour($scope.new_service_organization.hours[0])
          .success (data) ->
            $scope.new_service_organization.hours = []
            $scope.new_service_organization.hours.push(data.user_service_hour)
            $scope.user_service_organizations.push($scope.new_service_organization)
            $scope.new_service_organization.editing = false
            $scope.user_service_organizations.editing = false
            $scope.refreshPoints()
            $scope.previous_organization_list = []
            # reset previous organization list
            for user_service_organization in $scope.user_service_organizations
              if user_service_organization.hours.length <= 0
                $scope.previous_organization_list.push(user_service_organization)
      else
        UserServiceOrganizationService.saveNewServiceOrganization($scope.new_service_organization)
          .success (data) ->
            data.user_service_organization.hours = []
            data.user_service_organization.hours.push(data.user_service_hour)
            $scope.user_service_organizations.push(data.user_service_organization)
            $scope.new_service_organization.editing = false
            $scope.user_service_organizations.editing = false
            $scope.refreshPoints()

    $scope.saveHour = (parentIndex, index, serviceOrganizationId) ->
      if $scope.user_service_organizations[parentIndex].hours[index].new_hours != undefined and
         $scope.user_service_organizations[parentIndex].hours[index].new_date != undefined
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
      else
        window.confirm "Please enter the date and hours"

    $scope.deleteOrganization = (index) ->
      if window.confirm "Are you sure you want to delete this organization?"
        UserServiceOrganizationService.deleteServiceOrganization($scope.user_service_organizations[index], $scope.selected_semester.id)
          .success (data) ->
            $scope.user_service_organizations[index].hours = []
            deletedOrganization = $scope.user_service_organizations.splice(index,1)
            $scope.previous_organization_list.push(deletedOrganization[0])
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

    $scope.cancelNewOrganization = () ->
      $scope.new_service_organization.editing = false

    $scope.cancelHourEdit= (parentIndex, index) ->
      if $scope.user_service_organizations[parentIndex].hours[index].id
        $scope.user_service_organizations[parentIndex].hours[index].editing = false
      else
        $scope.user_service_organizations[parentIndex].hours.splice(index, 1)

      $scope.user_service_organizations[parentIndex].hours.editing = false

    $scope.addOrganization = () ->
      $scope.new_service_organization = {}
      $scope.new_service_organization.editing = true
      $scope.new_service_organization = UserServiceOrganizationService.newServiceOrganization($scope.student)
      $scope.new_service_organization.hours = []
      $scope.new_service_organization.hours.push(UserServiceOrganizationService.newServiceHour($scope.student, $scope.selected_semester.id, null))


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

    $scope.notInPreviousList = () ->
      $scope.new_service_organization.newOrganization = true

    $scope.selectAction = (selectedServiceOrg) ->
      $scope.new_service_organization = selectedServiceOrg
      $scope.new_service_organization.editing = true
      $scope.new_service_organization.hours = []
      $scope.new_service_organization.hours.push(UserServiceOrganizationService.newServiceHour($scope.student, $scope.selected_semester.id, selectedServiceOrg.id))

]
