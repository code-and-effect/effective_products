module Admin
  class EffectiveStampsDatatable < Effective::Datatable
    filters do
      scope :ready_to_issue
      scope :pending_applicant_approval
      scope :pending_stamp_request_purchase
      scope :issued
      scope :all
    end

    datatable do
      order :created_at

      col :updated_at, visible: false
      col :created_at, visible: false
      col :id, visible: false

      col :created_at, as: :date
      col :status, visible: false
      col :owner, search: :string

      col(:applicant, search: :string) do |stamp|
        if stamp.applicant.present?
          link_to(stamp.applicant, effective_memberships.edit_admin_applicant_path(stamp.applicant)) + ' ' + badges(stamp.applicant.status)
        end
      end

      col(:stamp_wizard, search: :string) do |stamp|
        if stamp.stamp_wizard.present?
          stamp.stamp_wizard.to_s + ' ' + badges(stamp.stamp_wizard.status)
        end
      end

      col(:email, visible: false) { |stamp| mail_to stamp.owner.email }
      col(:phone, visible: false) { |stamp| stamp.owner.phone }

      col :member_number, label: 'Member #' do |stamp|
        stamp.owner.try(:membership).try(:number)
      end

      col :name
      col :name_confirmation, visible: false

      col :category, search: EffectiveProducts.stamp_categories

      col :shipping_address
      col(:address1, visible: false) { |stamp| stamp.shipping_address.try(:address1) }
      col(:address2, visible: false) { |stamp| stamp.shipping_address.try(:address2) }
      col(:city, visible: false) { |stamp| stamp.shipping_address.try(:city) }
      col(:state_code, visible: false, label: 'Prov') { |stamp| stamp.shipping_address.try(:state_code) }
      col(:postal_code, visible: false, label: 'Postal') { |stamp| stamp.shipping_address.try(:postal_code) }
      col(:country_code, visible: false, label: 'Country') { |stamp| stamp.shipping_address.try(:country_code) }

      col :purchased_order, search: :string, visible: false
      col :price, as: :price, visible: false
      col :tax_exempt, visible: false
      col :qb_item_name, visible: false

      col :issued_at, as: :date

      actions_col
    end

    collection do
      Effective::Stamp.deep.all
    end
  end
end
