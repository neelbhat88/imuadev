# To Do's

1. Remove extra defers on all HTTP calls -- first wait on answer to question about it though

1. Cache Roadmap object in Angular so that it doesn't always make the rest call

1. **Tests** -> add , only: [:edit] to resources :users and see if test fails

1. Misc
  1. Status messages
  1. Loading gif
  1. If info not updated then redirect to update info page


# DEBT and QUESTIONS
- UsersController -> How to correctly send a 401 Unauthorized if the authenciate_user! fails in the application controller


# Angular Questions
1. HOW TO DO RSPEC TESTS?? Any good tutorials? Took forever to figure out how to mock an ActiveRecord call (see roadmap_repository_rspec.rb) and just gave up

1. Understand CSRF security with   before_filter :authenticate_user!
  skip_before_filter  :verify_authenticity_token

1. users_service.js methods returning just $http and then using .success() and .error() with the server returning error status --> Is this a good way to do it?

1. Roadmap.html

    ng-incude with a string built up reloads full page
    In roadmap.html See (http://lostechies.com/gabrielschenker/2013/12/28/angularjspart-6-templates/)

    ```html
    <div ng-show="selected.module" class="milestone ptl" ng-include="'/assets/add_'+selected.module.submoduleType.toLowerCase()+'.html'">
    ```
    but ```ng-include="'/assets/add_academics_gpa.html'"``` works just fine

1. Angular best practices for authorization (Admin only can see this page, etc)
   roles and permissions

1. Full angular header with different links for different people

1. Caching objects between pages, e.g. Roadmap can be cached after the first time you go to the roadmap page until the user refreshes their screen. Are there best practices around this?

1. ~~Page load blip~~ --> ng-cloak

# Don't forget
1. **Tests!**
1. Cache busting with Angular templates. Is this a solution? (https://github.com/pitr/angular-rails-templates)
