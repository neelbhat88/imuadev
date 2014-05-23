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

      get  '/organization/:id/roadmap' => 'organization#roadmap'
      get  '/organization/:id/modules' => 'organization#modules'

      post '/roadmap' => 'roadmap#create'

      post '/time_unit' => 'roadmap#create_time_unit'
      put  '/time_unit/:id' => 'roadmap#update_time_unit'
      delete '/time_unit/:id' => 'roadmap#delete_time_unit'

      post '/milestone' => 'roadmap#create_milestone'
      #get  '/milestone/defaults' => 'roadmap#default_milestones'

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
