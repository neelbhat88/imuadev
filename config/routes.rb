Imua::Application.routes.draw do
  get "organization/roadmap"

  devise_for :users, :skip => [:registrations]

  namespace :api do
    namespace :v1 do

      devise_scope :user do
        get 'current_user' => 'sessions#show_current_user'
      end

      resources :users do
        collection do
          put '/:id/update_password' => 'users#update_password'

          get  '/:id/time_unit/:time_unit_id/classes' => 'progress#user_classes'
          post '/:id/classes' => 'progress#add_user_class'
          put  '/:id/classes/:class_id' => 'progress#update_user_class'
          delete '/:id/classes/:class_id' => 'progress#delete_user_class'

          put '/:id/time_unit/next' => "users#move_to_next_semester"
          put '/:id/time_unit/previous' => "users#move_to_prev_semester"

          get  '/:id/time_unit/:time_unit_id/progress' => 'progress#all_modules_progress'
          get  '/:id/time_unit/:time_unit_id/progress/:module' => 'progress#module_progress'

          get   '/:id/time_unit/:time_unit_id/milestones/:module/yesno' => 'progress#yes_no_milestones'

          post  '/:id/time_unit/:time_unit_id/milestones/:milestone_id' => 'progress#add_user_milestone'
          delete  '/:id/time_unit/:time_unit_id/milestones/:milestone_id' => 'progress#delete_user_milestone'

          get    '/:id/expectations'        => 'expectations#all_user_expectations'
          get    '/:id/expectations/:title' => 'expectations#user_expectation'
          post   '/:id/expectations/:title' => 'expectations#add_user_expectation'
          put    '/:id/expectations/:title' => 'expectations#update_user_expectation'
          delete '/:id/expectations/:title' => 'expectations#delete_user_expectation'
        end
      end

      get  '/organization' => 'organization#all_organizations'
      get  '/organization/:id' => 'organization#get_organization'
      # params[:name]
      post '/organization' => 'organization#create_organization'
      # params[:id]
      # params[:name]
      put  '/organization/:id' => 'organization#update_organization'
      delete '/organization/:id' => 'organization#delete_organization'

      get  '/organization/:id/time_units' => 'organization#time_units'
      get  '/organization/:id/roadmap' => 'organization#roadmap'
      get  '/organization/:id/modules' => 'organization#modules'
      get  '/organization/:id/expectations' => 'organization#expectations'

      post '/roadmap' => 'roadmap#create'
      put  '/roadmap/:id' => 'roadmap#update'
      delete '/roadmap/:id' => 'roadmap#delete'

      post '/time_unit' => 'roadmap#create_time_unit'
      put  '/time_unit/:id' => 'roadmap#update_time_unit'
      delete '/time_unit/:id' => 'roadmap#delete_time_unit'

      post '/milestone' => 'roadmap#create_milestone'
      put  '/milestone/:id' => 'roadmap#update_milestone'
      delete '/milestone/:id' => 'roadmap#delete_milestone'

      post   '/expectation'     => 'expectation#create_expectation'
      put    '/expectation/:id' => 'expectation#update_expectation'
      delete '/expectation/:id' => 'expectation#delete_expectation'

    end # end :v1
  end # end :api

  get '/dashboard' => 'static#dashboard', as: 'dashboard'
  get '/*path' => redirect("/?goto=%{path}")
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
