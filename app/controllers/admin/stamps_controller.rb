module Admin
  class StampsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_products) }

    include Effective::CrudController

    # Admin can go straight to submitted
    submit :mark_as_submitted, 'Save'
    submit :mark_paid, 'Save and Mark Paid', redirect: :index

    on :mark_as_submitted, redirect: :index
    on :mark_as_issued, redirect: :index

  end
end
