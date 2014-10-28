Imua::Application.routes.draw do
  get "organization/roadmap"

  devise_for :users, :skip => [:registrations]

  namespace :api do
    namespace :v1 do

      devise_scope :user do
        get 'current_user' => 'sessions#show_current_user'
      end

      # **************************************
      #       *NEW WAY OF DOING ROUTES*
      # run foreman run rake routes to see what the routes look like
      # **************************************
      resources :organization, shallow: true do

        member do
          put 'users/reset_users_password' => 'users#reset_users_password'
          put 'users/reset_all_students_password' => 'users#reset_all_students_password'
        end

        resources :users, shallow: true do

          resources :user_class, except: [:new, :edit] do
            get 'history', on: :member # see http://guides.rubyonrails.org/routing.html#adding-more-restful-actions
          end

          resources :user_extracurricular_activity, except: [:new, :edit]
          resources :user_extracurricular_activity_detail, except: [:new, :edit]

          resources :assignment, except: [:new, :edit]
          resources :user_assignment, except: [:new, :edit, :show]

          resources :user_service_organization, except: [:new, :edit]
          resources :user_service_hour, except: [:new, :edit]

          resources :user_expectation, except: [:new, :edit, :create, :destroy] do
            # see http://guides.rubyonrails.org/routing.html#adding-more-restful-actions
            member do
              get 'history'
              put 'comment'
            end
          end
        end

      end


      # **************************************
      #       OLD WAY OF DOING ROUTES
      # As much as possible, let's move to the structure
      # above.
      # **************************************
      resources :users do
        collection do
          get ':id/task_assignable_users' => 'assignment#get_task_assignable_users'
          get ':id/task_assignable_users_tasks' => 'assignment#get_task_assignable_users_tasks'

          put '/:id/update_password' => 'users#update_password'

          put '/:id/time_unit/next' => "users#move_to_next_semester"
          put '/:id/time_unit/previous' => "users#move_to_prev_semester"

          get  '/:id/progress' => 'progress#overall_progress'
          get  '/:id/progress_2' => 'progress#user_progress'
          get  '/:id/student_dashboard' => 'progress#student_dashboard'
          get  '/:id/student_expectations' => 'progress#student_expectations'
          get  '/:id/time_unit/:time_unit_id/progress' => 'progress#all_modules_progress'
          get  '/:id/time_unit/:time_unit_id/progress/:module' => 'progress#module_progress'

          get   '/:id/time_unit/:time_unit_id/milestones/:module/yesno' => 'progress#yes_no_milestones'

          post  '/:id/time_unit/:time_unit_id/milestones/:milestone_id' => 'progress#add_user_milestone'
          delete  '/:id/time_unit/:time_unit_id/milestones/:milestone_id' => 'progress#delete_user_milestone'

          post '/:id/relationship/:assignee_id' => "users#assign"
          delete '/:id/relationship/:assignee_id' => "users#unassign"
          get '/:id/relationship/students' => 'users#get_assigned_students'
          get '/:id/relationship/mentors' => 'users#get_assigned_mentors'

          get '/:id/user_expectation_history' => 'user_expectation_history#get_user_expectation_history'
        end
      end

      get  'assignment/:id/collection'      => 'assignment#get_assignment_collection'
      post 'users/:id/assignment/broadcast' => 'assignment#broadcast'
      put  'assignment/:id/broadcast'       => 'assignment#broadcast_update'

      get 'user_assignment/:id/collect'       => 'user_assignment#collect'
      get 'users/:user_id/user_assignment/collect' => 'user_assignment#collect_all'

      get 'users/:id/user_with_contacts' => 'users#get_user_with_contacts'
      post 'users/:id/parent_guardian_contact' => 'parent_guardian_contact#create_parent_guardian_contact'
      put 'parent_guardian_contact/:id' => 'parent_guardian_contact#update_parent_guardian_contact'
      delete 'parent_guardian_contact/:id' => 'parent_guardian_contact#delete_parent_guardian_contact'

      get '/relationship/assigned_students_for_group' => 'users#get_assigned_students_for_group'
      get '/progress/recalculated_milestones' => 'progress#get_recalculated_milestones'

      get '/organization/:id/info_with_roadmap' => 'organization#organization_with_roadmap'
      get '/organization/:id/info_with_users' => 'organization#organization_with_users'

      get '/organization/:id/time_units' => 'organization#time_units'
      get '/organization/:id/roadmap' => 'organization#roadmap'
      get '/organization/:id/modules' => 'organization#modules'

      get '/organization/:id/tests' => 'test#get_org_tests'
      post '/org_test' => 'test#create_org_test'
      put '/org_test/:id' => 'test#update_org_test'
      delete '/org_test/:id' => 'test#delete_org_test'

      get '/users/:id/tests' => 'test#get_user_tests'
      post '/user_test' => 'test#create_user_test'
      put '/user_test/:id' => 'test#update_user_test'
      delete '/user_test/:id' => 'test#delete_user_test'

      get '/users/:id/parent_guardian_contacts' => 'parent_guardian_contact#get_parent_guardian_contacts'
      post '/parent_guardian_contact' => 'parent_guardian_contact#create_parent_guardian_contact'
      put '/parent_guardian_contact/:id' => 'parent_guardian_contact#update_parent_guardian_contact'
      delete '/parent_guardian_contact/:id' => 'parent_guardian_contact#delete_parent_guardian_contact'

      post '/roadmap' => 'roadmap#create'
      put  '/roadmap/:id' => 'roadmap#update'
      delete '/roadmap/:id' => 'roadmap#delete'

      post '/time_unit' => 'roadmap#create_time_unit'
      put  '/time_unit/:id' => 'roadmap#update_time_unit'
      delete '/time_unit/:id' => 'roadmap#delete_time_unit'

      get  '/milestone/:id/status' => 'milestone#get_milestone_status'
      post '/milestone' => 'milestone#create_milestone'
      put  '/milestone/:id' => 'milestone#update_milestone'
      delete '/milestone/:id' => 'milestone#delete_milestone'

      get    '/organization/:id/expectations'                 => 'expectation#get_expectations'
      post   '/organization/:id/expectations'                 => 'expectation#create_expectation'
      put    '/organization/:id/expectations/:expectation_id' => 'expectation#update_expectation'
      delete '/organization/:id/expectations/:expectation_id' => 'expectation#delete_expectation'

    end # end :v1
  end # end :api

  get '/forgot_password' => 'static#forgot_password'
  post '/reset_password' => 'static#reset_password'

  get '/login' => 'static#login'
  get '/marketing' => 'static#index'


  root :to => 'static#index'
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
