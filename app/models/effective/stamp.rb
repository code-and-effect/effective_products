# frozen_string_literal: true

module Effective
  class Stamp < ActiveRecord::Base
    acts_as_purchasable
    acts_as_addressable :shipping

    #CATEGORIES = ['Physical', 'Digital-only']
    CATEGORIES = ['Physical']

    log_changes if respond_to?(:log_changes)

    # This ring is charged to an owner
    belongs_to :owner, polymorphic: true

    # Through the stamp_wizard
    belongs_to :stamp_wizard, polymorphic: true, optional: true

    effective_resource do
      name               :string
      name_confirmation  :string

      category           :string

      # Admin issues stamps
      issued_at          :datetime   # Present when issued by an admin

      # Acts as Purchasable
      price             :integer
      qb_item_name      :string
      tax_exempt        :boolean

      timestamps
    end

    scope :deep, -> { includes(:owner) }
    scope :ready_to_issue, -> { purchased.where(issued_at: nil) }
    scope :issued, -> { where.not(issued_at: nil) }

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

    def mark_as_issued!
      update!(issued_at: Time.zone.now)
    end

    def issued?
      issued_at.present?
    end

    def physical?
      category == 'Physical'
    end

  end
end
