module Effective
  class StampWizardsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    include Effective::WizardController

    resource_scope -> { EffectiveProducts.StampWizard.deep.where(owner: current_user) }

  end
end
