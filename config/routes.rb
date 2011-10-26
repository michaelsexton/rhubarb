Rhubarb::Application.routes.draw do
  resources :blobs

  resources :references

  resources :major_projects

  resources :powerstations do
    collection do
      get 'fossil', 'renewable', 'map'
    end
  end

  resources :provinces do
    resources :deposits do
      collection do
        'resources'
      end
    end
  end

  resources :resources do
    collection do
      get 'aimr', 'year', 'state', 'identified'
    end
  end

  

  resources :users

  resources :user_sessions
  match 'login',  :to => "user_sessions#new", :as => :login
  match 'logout',  :to => "user_sessions#destroy", :as => :logout
    
  match 'account', :to => "users#index"

  resources :occurrences do
    collection do
      get 'map'
    end
  end

  resource :home do
    member do
      get 'new_features', 'help'
    end
  end
  match 'help', :to => "home#help"
  match 'new_features', :to => "home#new_features"


  resources :zones

  resources :deposits do
    collection do
      get 'map', 'resources', 'mineral_system', 'quality_check', 'atlas'
    end
  end



  root :to => 'home#index'

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

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
