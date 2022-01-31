module Admin
  class StampsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_products) }

    include Effective::CrudController

  end
end
