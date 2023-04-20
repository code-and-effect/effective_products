require 'effective_resources'
require 'effective_datatables'
require 'effective_products/engine'
require 'effective_products/version'

module EffectiveProducts

  def self.config_keys
    [
      :rings_table_name, :ring_wizards_table_name, :ring_wizard_class_name,
      :stamps_table_name, :stamp_wizards_table_name, :stamp_wizard_class_name,
      :stamp_categories,
      :layout, :use_effective_roles
    ]
  end

  include EffectiveGem

  def self.RingWizard
    ring_wizard_class_name&.constantize || Effective::RingWizard
  end

  def self.StampWizard
    stamp_wizard_class_name&.constantize || Effective::StampWizard
  end

  def self.stamp_categories
    Array(config[:stamp_categories])
  end

end
