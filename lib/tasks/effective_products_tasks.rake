namespace :effective_products do

  # bundle exec rake effective_products:seed
  task seed: :environment do
    load "#{__dir__}/../../db/seeds.rb"
  end

end
