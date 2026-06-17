module Admin
  class EffectiveRingsDatatable < Effective::Datatable
    filters do
      scope :submitted
      scope :issued
      scope :all
    end

    datatable do
      order :updated_at

      col :updated_at, visible: false
      col :created_at, as: :date, visible: false
      col :id, visible: false

      col :status

      col :owner, search: :string
      col :parent

      col(:first_name) { |ring| ring.owner.first_name }
      col(:last_name) { |ring| ring.owner.last_name }
      col(:email) { |ring| ring.owner.email }
      col(:phone) { |ring| ring.owner.phone }

      col :member_number, label: 'Member #' do |ring|
        ring.owner.try(:membership).try(:number)
      end

      if current_user.respond_to?(:shipping_address)
        col :user_shipping_address, label: "Shipping Address" do |ring|
          ring.owner.try(:shipping_address).try(:to_html)
        end

        col(:address1, visible: false) { |ring| ring&.owner.shipping_address.try(:address1) }
        col(:address2, visible: false) { |ring| ring&.owner.shipping_address.try(:address2) }
        col(:city, visible: false) { |ring| ring&.owner.shipping_address.try(:city) }
        col(:state_code, visible: false, label: 'Prov') { |ring| ring&.owner.shipping_address.try(:state_code) }
        col(:postal_code, visible: false, label: 'Postal') { |ring| ring&.owner.shipping_address.try(:postal_code) }
        col(:country_code, visible: false, label: 'Country') { |ring| ring&.owner.shipping_address.try(:country_code) }
      end

      col :size
      col :metal

      col :purchased_order, search: :string, visible: false
      col :price, as: :price, visible: false
      col :tax_exempt, visible: false
      col :qb_item_name, visible: false

      col :purchased_at, as: :date, visible: false
      col :submitted_at, as: :date, visible: false
      col :issued_at, as: :date

      actions_col
    end

    collection do
      Effective::Ring.deep.all
    end
  end
end
