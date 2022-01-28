# frozen_string_literal: true

Rails.application.routes.draw do
  mount EffectiveProducts::Engine => '/', as: 'effective_products'
end

EffectiveProducts::Engine.routes.draw do
  # Public routes
  scope module: 'effective' do
    resources :ring_wizards, only: [:new, :show, :destroy] do
      resources :build, controller: :ring_wizards, only: [:show, :update]
    end
  end

  namespace :admin do
    resources :ring_wizards, except: [:new, :create, :show]

    resources :rings, only: [:index, :show] do
      post :mark_as_issued, on: :member
    end
  end

end
