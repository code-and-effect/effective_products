# frozen_string_literal: true

Rails.application.routes.draw do
  mount EffectiveProducts::Engine => '/', as: 'effective_products'
end

EffectiveProducts::Engine.routes.draw do
  # Public routes
  scope module: 'effective' do
    resources :ring_wizards, name: :ring_wizard, only: [:new, :show, :destroy] do
      resources :build, controller: :ring_wizards, only: [:show, :update]
    end

    resources :stamp_wizards, name: :stamp_wizard, only: [:new, :show, :destroy] do
      resources :build, controller: :stamp_wizards, only: [:show, :update]
    end
  end

  namespace :admin do
    resources :ring_wizards, except: [:new, :create, :show]

    resources :rings, only: [:index, :show] do
      post :mark_as_issued, on: :member
    end

    resources :stamps do
      post :mark_as_issued, on: :member
    end
  end

end
