module Admin
  class EffectiveRingsDatatable < Effective::Datatable
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

      col :first_name
      col :last_name

      col :email
      col :phone

      col :member_number, label: 'Member #' do |ring|
        ring.owner.try(:membership).try(:number)
      end

      col :shipping_address, label: 'Address'

      col :size
      col :metal
      col :issued_at

      actions_col
    end

    collection do
      Effective::Ring.deep.all
    end
  end
end
