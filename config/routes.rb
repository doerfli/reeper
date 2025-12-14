Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/health', to: 'health#index'

  get '/welcome', to: 'welcome#index'

  get '/profile', to: 'profile#index'
  get '/profile/change_password', to: 'profile#change_password', as: 'change_password'

  get '/auth/auth0/callback' => 'auth0#callback', as: 'auth0_callback'
  get '/auth/failure' => 'auth0#failure', as: 'auth0_failure'
  get '/auth/logout' => 'auth0#logout', as: 'auth0_logout'

  resources :recipes do
    collection do
      get 'filter_by_tag/:tagid' => :filter_by_tag, as: 'filter_by_tag'
      get 'search(/:term)' => :search, as: 'search'
      get 'new_magic' => :new_magic
    end
    member do
      put 'favorite'
    end
    resources :recipe_images, only: [:new, :create] do
      collection do
        get 'delete_select'
        put 'delete'
      end
    end
  end
  resources :tags do
    collection do
      get 'search(/:term)' => :search, as: 'search'
    end
  end

  resources :ocr do
    collection do
      post 'scan'
    end
    member do
      post 'save_text'
      post 'cleanup_with_gpt'
    end
  end

  root to: 'recipes#index'
end
