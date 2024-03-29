module EffectiveProducts
  class Engine < ::Rails::Engine
    engine_name 'effective_products'

    # Set up our default configuration options.
    initializer 'effective_products.defaults', before: :load_config_initializers do |app|
      eval File.read("#{config.root}/config/effective_products.rb")
    end

    # Include acts_as_addressable concern and allow any ActiveRecord object to call it
    initializer 'effective_products.active_record' do |app|
      app.config.to_prepare do
        ActiveRecord::Base.extend(EffectiveProductsRingWizard::Base)
        ActiveRecord::Base.extend(EffectiveProductsStampWizard::Base)
      end
    end

  end
end
