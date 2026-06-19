# frozen_string_literal: true

module Effective
  class Stamp < ActiveRecord::Base
    self.table_name = (EffectiveProducts.stamps_table_name || :stamps).to_s

    acts_as_purchasable

    acts_as_statused(
      :draft,     # Built in an application
      :submitted, # Submitted by an applicant or stamp wizard
      :issued     # Issued by an admin
    )

    log_changes if respond_to?(:log_changes)

    # This stamp is charged to an owner
    belongs_to :owner, polymorphic: true
    accepts_nested_attributes_for :owner, reject_if: :all_blank

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

    scope :deep, -> { includes(:purchased_order, :parent, owner: [:addresses, :membership]) }
    scope :ready_to_issue, -> { submitted }
    scope :not_issued, -> { where.not(status: :issued) }
    scope :created_by_admin, -> { where(created_by_admin: true) }

    validates :parent, presence: true, unless: -> { created_by_admin? }

    validates :name, presence: true
    validates :name_confirmation, presence: true
    validates :category, presence: true

    validate(if: -> { name.present? && name_confirmation.present? }) do
      errors.add(:name_confirmation, "doesn't match name") unless name == name_confirmation
    end

    validate(if: -> { owner.present? }, unless: -> { category == 'Digital-only' }) do
      errors.add(:owner, "must have a shipping address") unless owner.try(:shipping_address).present?
    end

    def to_s
      [model_name.human, name.presence, category.presence].compact.join(' - ')
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

    # This is the Admin Save and Mark Paid action
    def mark_paid!
      category = owner&.membership&.category

      assign_attributes(
        price: (category&.stamp_fee || 0),
        tax_exempt: (category&.stamp_fee_tax_exempt || false),
        qb_item_name: (category&.stamp_fee_qb_item_name || 'Professional Stamp')
      )

      submit!

      Effective::Order.new(items: self, user: owner).mark_as_purchased!

      true
    end
  end
end
