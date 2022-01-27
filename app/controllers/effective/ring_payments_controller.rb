module Effective
  class RingPaymentsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    include Effective::WizardController

    resource_scope -> { EffectiveProducts.RingPayment.deep.where(owner: current_user) }

    # Allow only 1 in-progress application at a time
    before_action(only: [:new, :show], unless: -> { resource&.done? }) do
      existing = resource_scope.in_progress.where.not(id: resource).first

      if existing.present?
        flash[:success] = "You have been redirected to your existing in progress payment"
        redirect_to effective_products.ring_payment_build_path(existing, existing.next_step)
      end
    end

    after_save do
      flash.now[:success] = ''
    end

    private

    def permitted_params
      model = (params.key?(:effective_ring_payment) ? :effective_ring_payment : :ring_payment)
      params.require(model).permit!.except(:status, :status_steps, :wizard_steps, :submitted_at)
    end

  end
end
