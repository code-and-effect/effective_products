EffectiveProducts.setup do |config|
  config.rings_table_name = :rings
  config.ring_wizards_table_name = :ring_wizards
  config.stamps_table_name = :stamps
  config.stamp_payments_table_name = :stamp_payments

  # Layout Settings
  # Configure the Layout per controller, or all at once
  # config.layout = { application: 'application', admin: 'admin' }

  # Payment Wizard Settings
  # config.ring_wizards_class_name = 'Effective::RingWizard'
  # config.stamp_payments_class_name = 'Effective::StampPayment'

  # Use effective roles. Not sure what this does yet.
  config.use_effective_roles = true

end
