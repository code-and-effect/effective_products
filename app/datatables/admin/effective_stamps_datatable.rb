module Admin
  class EffectiveStampsDatatable < Effective::Datatable
    filters do
      scope :ready_to_issue
      scope :issued
      scope :all
    end

    datatable do
      order :updated_at

      col :updated_at, visible: false
      col :created_at, visible: false
      col :id, visible: false

      col :created_at, as: :date
      col :owner, search: :string

      col :applicant, visible: false
      col :stamp_wizard, visible: false

      col(:email) { |stamp| mail_to stamp.owner.email }
      col(:phone) { |stamp| stamp.owner.phone }

      col :member_number, label: 'Member #' do |stamp|
        stamp.owner.try(:membership).try(:number)
      end

      col :name
      col :name_confirmation, visible: false

      col :category, search: EffectiveProducts.stamp_categories

      col :shipping_address, visible: false
      col(:address1) { |stamp| stamp.shipping_address.try(:address1) }
      col(:address2) { |stamp| stamp.shipping_address.try(:address2) }
      col(:city) { |stamp| stamp.shipping_address.try(:city) }
      col(:state_code, label: 'Prov') { |stamp| stamp.shipping_address.try(:state_code) }
      col(:postal_code, label: 'Postal') { |stamp| stamp.shipping_address.try(:postal_code) }
      col(:country_code, label: 'Country') { |stamp| stamp.shipping_address.try(:country_code) }

      col :purchased_order, visible: false
      col :price, as: :price, visible: false
      col :tax_exempt, visible: false
      col :qb_item_name, visible: false

      col :status, visible: false
      col :issued_at

      actions_col
    end

    collection do
      Effective::Stamp.deep.all
    end
  end
end
