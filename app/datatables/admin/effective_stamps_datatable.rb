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

      col(:email) { |stamp| stamp.owner.email }
      col(:phone) { |stamp| stamp.owner.phone }

      col :member_number, label: 'Member #' do |stamp|
        stamp.owner.try(:membership).try(:number)
      end

      col :name
      col :name_confirmation, visible: false

      col :category, visible: false

      col :shipping_address, label: 'Address'

      col :purchased_order, visible: false
      col :price, visible: false
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
