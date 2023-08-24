EffectiveProducts.setup do |config|
  # Layout Settings
  # Configure the Layout per controller, or all at once
  # config.layout = { application: 'application', admin: 'admin' }

  # Payment Wizard Settings
  # config.ring_wizards_class_name = 'Effective::RingWizard'
  # config.stamp_wizards_class_name = 'Effective::StampWizard'

  # The available stamp categories
  config.stamp_categories = ['Physical', 'Digital-only', 'Stamp', 'Stamp and Certificate']

  # Use effective roles. Not sure what this does yet.
  config.use_effective_roles = true

end
