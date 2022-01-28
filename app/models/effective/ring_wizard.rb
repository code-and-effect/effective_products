module Effective
  class RingWizard < ActiveRecord::Base
    self.table_name = EffectiveProducts.ring_wizards_table_name.to_s

    effective_products_ring_wizard
  end
end
