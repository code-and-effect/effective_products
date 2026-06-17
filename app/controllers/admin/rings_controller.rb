module Admin
  class RingsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_products) }

    include Effective::CrudController

    # Admin can go straight to submitted
    submit :mark_as_submitted, 'Save'

    on :mark_as_submitted, redirect: :index
    on :mark_as_issued, redirect: :index

  end
end
