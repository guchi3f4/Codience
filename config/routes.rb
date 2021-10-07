Rails.application.routes.draw do
  devise_for :users
  root to: "homes#top"

  resources :users, only: [:edit, :update, :index, :show] do
    resource :user_relations, only: [:create, :destroy]
    member do
      get :following, :followers, :bookmarks, :posts
    end
  end

  resources :articles do
    resources :article_comments, only: [:create, :destroy]
    resource :article_favorites, only: [:create, :destroy]
    resource :article_bookmarks, only: [:create, :destroy]
  end
end
