require 'effective_resources'
require 'effective_datatables'
require 'effective_products/engine'
require 'effective_products/version'

module EffectiveProducts

  def self.config_keys
    [
      :layout
    ]
  end

  include EffectiveGem

end
