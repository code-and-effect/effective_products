class CreateEffectiveProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :rings do |t|
      t.integer :owner_id
      t.string :owner_type

      # This could be a RingWizard, or Blank (admin created)
      t.integer :parent_id
      t.string :parent_type

      t.integer :size
      t.string :metal

      t.datetime :submitted_at
      t.datetime :issued_at

      t.boolean :created_by_admin, default: false

      # Acts as Statused
      t.string :status
      t.text :status_steps

      # Acts as purchasable
      t.integer :purchased_order_id
      t.integer :price
      t.boolean :tax_exempt, default: false
      t.string :qb_item_name

      t.timestamps
    end

    add_index :rings, [:owner_id, :owner_type]
    add_index :rings, [:parent_id, :parent_type]

    create_table :ring_wizards do |t|
      t.string :token

      t.integer :owner_id
      t.string :owner_type

      # Acts as Statused
      t.string :status
      t.text :status_steps

      # Acts as Wizard
      t.text :wizard_steps

      # Dates
      t.datetime :submitted_at

      t.datetime :updated_at
      t.datetime :created_at
    end

    add_index :ring_wizards, [:owner_id, :owner_type]
    add_index :ring_wizards, :status
    add_index :ring_wizards, :token

    create_table :stamps do |t|
      t.integer :owner_id
      t.string :owner_type

      # This could be a StampWizard, an Applicant, a FeePayment, or Blank (admin created)
      t.integer :parent_id
      t.string :parent_type

      t.string :name
      t.string :name_confirmation

      t.string :category

      t.datetime :submitted_at
      t.datetime :issued_at

      t.boolean :created_by_admin, default: false

      # Acts as Statused
      t.string :status
      t.text :status_steps

      # Acts as purchasable
      t.integer :purchased_order_id
      t.integer :price
      t.boolean :tax_exempt, default: false
      t.string :qb_item_name

      t.timestamps
    end

    add_index :stamps, [:owner_id, :owner_type]
    add_index :stamps, [:parent_id, :parent_type]

    create_table :stamp_wizards do |t|
      t.string :token

      t.integer :owner_id
      t.string :owner_type

      # Acts as Statused
      t.string :status
      t.text :status_steps

      # Acts as Wizard
      t.text :wizard_steps

      # Dates
      t.datetime :submitted_at

      t.datetime :updated_at
      t.datetime :created_at
    end

    add_index :stamp_wizards, [:owner_id, :owner_type]
    add_index :stamp_wizards, :status
    add_index :stamp_wizards, :token

  end
end
