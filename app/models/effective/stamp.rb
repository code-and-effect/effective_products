# frozen_string_literal: true

module Effective
  class Stamp < ActiveRecord::Base
    acts_as_purchasable
    acts_as_addressable :shipping

    acts_as_statused(
      :draft,     # Built in an application
      :submitted, # Submitted by an applicant or stamp wizard
      :issued     # Issued by an admin
    )

    #CATEGORIES = ['Physical', 'Digital-only']
    CATEGORIES = ['Physical']

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

    scope :deep, -> { includes(:owner) }

    scope :with_approved_applicants, -> { where(applicant_id: EffectiveMemberships.Applicant.approved) }
    scope :with_stamp_wizards, -> { where(applicant_id: nil).where.not(stamp_wizard_id: nil) }

    scope :ready_to_issue, -> {
      with_approved_applicants.or(with_stamp_wizards).purchased.where.not(issued_at: nil)
    }

    validates :category, presence: true, inclusion: { in: CATEGORIES }
    validates :name, presence: true
    validates :name_confirmation, presence: true

    validate(if: -> { name.present? && name_confirmation.present? }) do
      self.errors.add(:name_confirmation, "doesn't match name") unless name == name_confirmation
    end

    validate(if: -> { physical? }) do
      self.errors.add(:shipping_address, "can't be blank when physical stamp") unless shipping_address.present?
    end

    def to_s
      ['Professional Stamp', *name.presence].join(' ')
    end

    def issued?
      issued_at.present?
    end

    def mark_as_issued!
      issued!
    end

    def physical?
      category == 'Physical'
    end

    def created_by_admin?
      stamp_wizard_id.blank? && applicant_id.blank?
    end

    # Called by an application when submitted
    # Called by a stamp wizard when submitted
    def submit!
      raise('expected a purchased order') unless purchased?
      submitted!
    end

    # This is the Admin Save and Mark Paid action
    def mark_paid!
      raise('expected an user with a membership category') unless owner && owner.try(:membership).present?

      category = owner.membership.categories.first

      assign_attributes(
        price: category.stamp_fee,
        tax_exempt: category.stamp_fee_tax_exempt,
        qb_item_name: category.stamp_fee_qb_item_name
      )

      save!
      Effective::Order.new(items: self, user: owner).mark_as_purchased!
    end

  end
end
