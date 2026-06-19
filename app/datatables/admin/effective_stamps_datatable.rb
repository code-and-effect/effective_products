module Admin
  class EffectiveStampsDatatable < Effective::Datatable
    filters do
      scope :submitted
      scope :issued
      scope :all
    end

    datatable do
      order :submitted_at

      col :updated_at, visible: false
      col :created_at, as: :date, visible: false
      col :id, visible: false

      col :status

      col :submitted_at, as: :date
      col :purchased_at, as: :date, visible: false
      col :issued_at, as: :date, visible: false

      col :owner, label: 'User', search: :string
      col :parent

      col(:email, visible: false) { |stamp| mail_to(stamp.owner.email) }
      col(:phone, visible: false) { |stamp| stamp.owner.phone }

      col :member_number, label: 'Member #' do |stamp|
        stamp.owner.try(:membership).try(:number)
      end

      col :name
      col :name_confirmation, visible: false

      col :category, search: EffectiveProducts.stamp_categories

      col(:shipping_address, visible: true) { |stamp| stamp.owner.try(:shipping_address).try(:to_html) }
      col(:address1, visible: false) { |stamp| stamp.owner.try(:shipping_address).try(:address1) }
      col(:address2, visible: false) { |stamp| stamp.owner.try(:shipping_address).try(:address2) }
      col(:city, visible: false) { |stamp| stamp.owner.try(:shipping_address).try(:city) }
      col(:state_code, visible: false, label: 'Prov') { |stamp| stamp.owner.try(:shipping_address).try(:state_code) }
      col(:postal_code, visible: false, label: 'Postal') { |stamp| stamp.owner.try(:shipping_address).try(:postal_code) }
      col(:country_code, visible: false, label: 'Country') { |stamp| stamp.owner.try(:shipping_address).try(:country_code) }

      col :purchased_order, search: :string, visible: false
      col :price, as: :price, visible: false
      col :tax_exempt, visible: false
      col :qb_item_name, visible: false

      actions_col
    end

    collection do
      Effective::Stamp.deep.all
    end
  end
end
