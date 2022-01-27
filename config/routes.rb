# frozen_string_literal: true

Rails.application.routes.draw do
  mount EffectiveProducts::Engine => '/', as: 'effective_products'
end

EffectiveProducts::Engine.routes.draw do
  # Public routes
  scope module: 'effective' do
  end

  namespace :admin do
  end

end
