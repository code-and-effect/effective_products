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
      val(:current_category, label: 'Current Category', search: category_search_collection, sort: false, visible: false) do |stamp|
        stamp.owner.try(:membership).try(:categories).to_a.map(&:to_s).presence
      end.search do |collection, term, _, index|
        collection.select { |row| Array(row[index]).include?(term.to_s) }
      end
      val(:applicant_category, label: 'Applicant Category', search: category_search_collection, sort: false, visible: false) do |stamp|
        stamp.applicant_categories.presence
      end.search do |collection, term, _, index|
        collection.select { |row| Array(row[index]).include?(term.to_s) }
      end
      val(:applicant_status, label: 'Applicant Status', search: applicant_status_search_collection, sort: false, visible: false) do |stamp|
        stamp.applicant_statuses.presence
      end.search do |collection, term, _, index|
        collection.select { |row| Array(row[index]).include?(term.to_s) }
      end
      col :parent, badge: false, visible: false
      col(:email, visible: false) { |stamp| mail_to(stamp.owner.email) }
      col(:phone, visible: false) { |stamp| stamp.owner.phone }

      col :member_number, label: 'Member #' do |stamp|
        stamp.owner.try(:membership).try(:number)
      end

      col :name
      col :name_confirmation, visible: false

      col :stamp_category, search: EffectiveProducts.stamp_categories do |stamp|
        stamp.category
      end

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

    def category_search_collection
      return false unless defined?(EffectiveMemberships)
      return false unless view.current_user.class.try(:effective_memberships_user?)

      EffectiveMemberships.Category.sorted.map(&:to_s)
    end

    def applicant_status_search_collection
      return false unless defined?(EffectiveMemberships)
      return false unless view.current_user.class.try(:effective_memberships_user?)

      EffectiveMemberships.Applicant.const_get(:STATUSES).map { |status| status.to_s.humanize }
    end
  end
end
