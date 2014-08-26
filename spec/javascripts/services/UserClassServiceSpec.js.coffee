# TODO: Need to figure out how to correctly test this!
# Maybe here: http://nathanleclaire.com/blog/2014/04/12/unit-testing-services-in-angularjs-for-fun-and-for-profit/

xdescribe "UserClassService", () ->
  $service = null
  $http = null
  constants = null

  # Load the module
  beforeEach module "myApp"
  beforeEach inject (UserClassService, _$http_, _CONSTANTS_) ->
    $service = UserClassService
    $http = _$http_
    constants = _CONSTANTS_

  beforeEach () ->
    $service "UserClassService", {$http: $http, CONSTANTS: constants}

  it "new() returns an object", () ->
    user_class = $service.get_gpa({id: 1}, 1)
    expect(user_class).toNotEqual(null)
