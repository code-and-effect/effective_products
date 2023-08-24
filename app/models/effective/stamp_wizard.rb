module Effective
  class StampWizard < ActiveRecord::Base
    self.table_name = (EffectiveProducts.stamp_wizards_table_name || :stamp_wizards).to_s

    effective_products_stamp_wizard
  end
end
