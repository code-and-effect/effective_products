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

      col(:first_name) { |stamp| stamp.owner.first_name }
      col(:last_name) { |stamp| stamp.owner.last_name }
      col(:email) { |stamp| stamp.owner.email }
      col(:phone) { |stamp| stamp.owner.phone }

      col :member_number, label: 'Member #' do |stamp|
        stamp.owner.try(:membership).try(:number)
      end

      col :category
      col :name
      col :name_confirmation

      col :shipping_address, label: 'Address'

      col :issued_at

      actions_col
    end

    collection do
      Effective::Stamp.deep.all
    end
  end
end
