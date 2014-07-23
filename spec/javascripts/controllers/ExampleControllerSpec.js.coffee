describe "ExampleController", () ->
  appCtrl = null
  scope = null

  # Need these next two beforeEach's in all test files
  beforeEach module "myApp"
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    appCtrl = $controller "ExampleController", {$scope: scope}

  it "should set greeting", () ->
    expect(scope.greeting).toBe("Hello World")

  it "sayGreeting should return correct greeting", () ->
    expect(scope.sayGreeting()).toBe("Hello World! This works!")

# More examples below:
# http://stackoverflow.com/questions/14123306/in-angular-js-while-testing-the-controller-got-unknown-provider

# Run JS tests by typing foreman run rake jasmine in console and then going to http://localhost:8888
