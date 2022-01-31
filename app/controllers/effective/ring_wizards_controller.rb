module Effective
  class RingWizardsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    include Effective::WizardController

    resource_scope -> { EffectiveProducts.RingWizard.deep.where(owner: current_user) }

  end
end
