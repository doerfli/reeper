Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :recipes do
    collection do
      get 'filter_by_tag/:tagid' => :filter_by_tag, as: 'filter_by_tag'
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

  root to: 'recipes#index'
end
