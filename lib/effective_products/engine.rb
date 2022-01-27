module EffectiveProducts
  class Engine < ::Rails::Engine
    engine_name 'effective_products'

    # Set up our default configuration options.
    initializer 'effective_products.defaults', before: :load_config_initializers do |app|
      eval File.read("#{config.root}/config/effective_products.rb")
    end

    # Include acts_as_addressable concern and allow any ActiveRecord object to call it
    initializer 'effective_products.active_record' do |app|
      ActiveSupport.on_load :active_record do
        ActiveRecord::Base.extend(EffectiveProductsRingPayment::Base)
      end
    end

  end
end
