Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :recipes do
    collection do
      get 'filter_by_tag/:tagid' => :filter_by_tag, as: 'filter_by_tag'
      get 'search(/:term)' => :search, as: 'search'
    end
    member do
      put 'favorite'
      put 'ocr'
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

  resources :ocr

  root to: 'recipes#index'
end
