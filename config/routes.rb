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
        end
      end

      get  '/organization' => 'organization#all_organizations'
      get  '/organization/:id' => 'organization#get_organization'
      post '/organization' => 'organization#create_organization'
      put  '/organization/:id' => 'organization#update_organization'
      delete '/organization/:id' => 'organization#delete_organization'

      get  '/organization/:id/time_units' => 'organization#time_units'
      get  '/organization/:id/roadmap' => 'organization#roadmap'
      get  '/organization/:id/modules' => 'organization#modules'

      post '/roadmap' => 'roadmap#create'
      put  '/roadmap/:id' => 'roadmap#update'
      delete '/roadmap/:id' => 'roadmap#delete'

      post '/time_unit' => 'roadmap#create_time_unit'
      put  '/time_unit/:id' => 'roadmap#update_time_unit'
      delete '/time_unit/:id' => 'roadmap#delete_time_unit'

      get '/milestone/default/:module/:submodule' => 'roadmap#default_milestone'
      post '/milestone' => 'roadmap#create_milestone'
      put  '/milestone/:id' => 'roadmap#update_milestone'
      delete '/milestone/:id' => 'roadmap#delete_milestone'

      # ToDo: Don't like this being a POST but leaving it for now for sake of getting this done
      post  '/progress/modules' => 'progress#all_modules_progress'

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
