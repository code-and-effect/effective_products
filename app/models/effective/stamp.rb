# frozen_string_literal: true

module Effective
  class Stamp < ActiveRecord::Base
    self.table_name = (EffectiveProducts.stamps_table_name || :stamps).to_s

    acts_as_purchasable
    acts_as_addressable :shipping

    acts_as_statused(
      :draft,     # Built in an application
      :submitted, # Submitted by an applicant or stamp wizard
      :issued     # Issued by an admin
    )

    log_changes if respond_to?(:log_changes)

    # This stamp is charged to an owner
    belongs_to :owner, polymorphic: true

    # This could be a StampWizard, an Applicant, a FeePayment, or Blank (admin created)
    belongs_to :parent, polymorphic: true, optional: true

    effective_resource do
      name               :string
      name_confirmation  :string

      category           :string

      submitted_at       :datetime
      issued_at          :datetime   # Present when issued by an admin

      created_by_admin   :boolean

      # Acts as Statused
      status            :string
      status_steps      :text

      # Acts as Purchasable
      price             :integer
      qb_item_name      :string
      tax_exempt        :boolean

      timestamps
    end

    scope :deep, -> { includes(:addresses, :purchased_order, :parent, owner: [:membership]) }

    scope :ready_to_issue, -> { submitted }
    scope :not_issued, -> { where.not(status: :issued) }

    scope :created_by_admin, -> { where(created_by_admin: true) }

    before_validation(if: -> { created_by_admin? && owner.present? }) do
      category = owner.membership&.category

      assign_attributes(
        price: (category&.stamp_fee || 0),
        tax_exempt: (category&.stamp_fee_tax_exempt || false),
        qb_item_name: (category&.stamp_fee_qb_item_name || 'Professional Stamp')
      )
    end

    validates :name, presence: true
    validates :name_confirmation, presence: true
    validates :category, presence: true
    validates :shipping_address, presence: true, unless: -> { category == 'Digital-only' }

    validates :parent, presence: true, unless: -> { created_by_admin? }

    validate(if: -> { name.present? && name_confirmation.present? }) do
      errors.add(:name_confirmation, "doesn't match name") unless name == name_confirmation
    end

    def to_s
      [
        model_name.human,
        ('Replacement' if parent_stamp_wizard?),
        '-',
        name.presence,
        ("- #{category}" if category.present?)
      ].compact.join(' ')
    end

    def parent_stamp_wizard?
      parent_type.to_s.include?('StampWizard')
    end

    # Called by a stamp wizard, applicant or fee payment when submitted
    def submit!
      submitted!
    end

    # Admin action
    def mark_as_submitted!
      submitted!
    end

    # Admin action
    def mark_as_issued!
      issued!
    end

  end
end
