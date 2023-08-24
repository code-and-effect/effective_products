# frozen_string_literal: true

module Effective
  class Ring < ActiveRecord::Base
    self.table_name = (EffectiveProducts.rings_table_name || :rings).to_s

    SIZES = [3, 4, 5, 6, 7, 8]
    TITANIUM_SIZES = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
    METALS = ['14k Yellow Gold', 'Sterling Silver', 'Titanium']

    acts_as_purchasable
    acts_as_addressable :shipping

    log_changes if respond_to?(:log_changes)

    # This ring is charged to an owner
    belongs_to :owner, polymorphic: true

    # Through the ring_wizard
    belongs_to :ring_wizard, polymorphic: true, optional: true

    effective_resource do
      size               :integer
      metal              :string

      issued_at          :datetime   # Present when issued by an admin

      # Acts as Purchasable
      price             :integer
      qb_item_name      :string
      tax_exempt        :boolean

      timestamps
    end

    scope :deep, -> { includes(:addresses, owner: [:membership]) }

    scope :ready_to_issue, -> { purchased.where(issued_at: nil) }
    scope :issued, -> { where.not(issued_at: nil) }

    validates :metal, presence: true, inclusion: { in: METALS }

    validates :size, presence: true
    validates :size, inclusion: { in: TITANIUM_SIZES }, if: -> { metal == 'Titanium' }
    validates :size, inclusion: { in: SIZES }, if: -> { metal != 'Titanium' }

    def to_s
      ["Chemist's Ring", (" - #{metal} size #{size}" if metal.present? && size.present?)].compact.join
    end

    def mark_as_issued!
      update!(issued_at: Time.zone.now)
    end

    def submitted?
      purchased?
    end

    def issued?
      issued_at.present?
    end

  end
end
