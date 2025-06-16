# frozen_string_literal: true

module Effective
  class Stamp < ActiveRecord::Base
    self.table_name = (EffectiveProducts.stamps_table_name || :stamps).to_s

    acts_as_purchasable
    acts_as_addressable :shipping

    attr_accessor :admin_action

    acts_as_statused(
      :draft,     # Built in an application
      :submitted, # Submitted by an applicant or stamp wizard
      :issued     # Issued by an admin
    )

    log_changes if respond_to?(:log_changes)

    # This stamp is charged to an owner
    belongs_to :owner, polymorphic: true

    # Sometimes a stamp is built through an applicant
    belongs_to :applicant, polymorphic: true, optional: true

    # Other times through the stamp_wizard
    belongs_to :stamp_wizard, polymorphic: true, optional: true

    effective_resource do
      name               :string
      name_confirmation  :string

      category           :string

      # Admin issues stamps
      issued_at          :datetime   # Present when issued by an admin

      # Acts as Statused
      status            :string
      status_steps      :text

      # Acts as Purchasable
      price             :integer
      qb_item_name      :string
      tax_exempt        :boolean

      timestamps
    end

    scope :deep, -> { includes(:addresses, :purchased_order, owner: [:membership], applicant: [:category, :user], stamp_wizard: [:user]) }
    scope :not_issued, -> { where.not(status: :issued) }

    scope :with_approved_applicants, -> { where(applicant_id: EffectiveMemberships.Applicant.approved) }
    scope :with_unapproved_applicants, -> { where.not(applicant_id: nil).where.not(applicant_id: EffectiveMemberships.Applicant.approved) }

    scope :with_purchased_stamp_wizards, -> { purchased.where.not(stamp_wizard_id: nil) }
    scope :with_not_purchased_stamp_wizards, -> { not_purchased.where.not(stamp_wizard_id: nil) }

    scope :created_by_admin, -> { submitted.where(applicant_id: nil, stamp_wizard_id: nil) }

    # Datatable Scopes
    scope :ready_to_issue, -> {
      with_approved_applicants.or(with_purchased_stamp_wizards).or(created_by_admin).submitted
    }

    scope :pending, -> { pending_applicant_approval.or(pending_stamp_request_purchase) }
    scope :pending_applicant_approval, -> { not_issued.with_unapproved_applicants }
    scope :pending_stamp_request_purchase, -> { not_issued.with_not_purchased_stamp_wizards }

    validates :name, presence: true
    validates :name_confirmation, presence: true
    validates :category, presence: true
    validates :shipping_address, presence: true, unless: -> { category == 'Digital-only' }

    validate(if: -> { name.present? && name_confirmation.present? }) do
      errors.add(:name_confirmation, "doesn't match name") unless name == name_confirmation
    end

    validate(if: -> { admin_action }) do
      errors.add(:owner_id, "must have a membership") unless owner && owner.try(:membership).present?
    end

    def to_s
      [
        model_name.human, 
        ('Replacement' if stamp_wizard_id_was.present?), 
        '-',
        name.presence, 
        ("- #{category}" if category.present?)
      ].compact.join(' ')
    end

    def mark_as_submitted!
      submitted!
    end

    def mark_as_issued!
      issued!
    end

    def created_by_admin?
      stamp_wizard_id.blank? && applicant_id.blank?
    end

    # Called by an application when submitted
    # Called by a stamp wizard when submitted
    def submit!
      raise('expected a purchased order') unless (purchased? || applicant&.submit_order&.purchased?)
      submitted!
    end

    # This is the Admin Save and Mark Paid action
    def mark_paid!
      assign_attributes(admin_action: true)

      category = owner&.membership&.categories&.first

      if category.present?
        assign_attributes(
          price: category.stamp_fee,
          tax_exempt: category.stamp_fee_tax_exempt,
          qb_item_name: category.stamp_fee_qb_item_name
        )
      end

      submitted! # Will fail with invalid owner membership anyway

      if category.present?
        Effective::Order.new(items: self, user: owner).mark_as_purchased!
      end

      true
    end

  end
end
