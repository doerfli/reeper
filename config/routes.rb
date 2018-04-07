Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :recipes do
    resources :recipe_images, only: [:new, :create] do
      collection do
        get 'delete_select'
        put 'delete'
      end
    end
  end
  resources :tags

  root to: 'recipes#index'
end
