module Effective
  class RingPayment < ActiveRecord::Base
    self.table_name = EffectiveProducts.ring_payments_table_name.to_s

    effective_products_ring_payment
  end
end
