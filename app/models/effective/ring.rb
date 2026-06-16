# frozen_string_literal: true

module Effective
  class Ring < ActiveRecord::Base
    self.table_name = (EffectiveProducts.rings_table_name || :rings).to_s

    SIZES = [3, 4, 5, 6, 7, 8]
    TITANIUM_SIZES = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
    METALS = ['14k Yellow Gold', 'Sterling Silver', 'Titanium']

    acts_as_purchasable
    acts_as_addressable :shipping

    acts_as_statused(
      :draft,     # Built in an application
      :submitted, # Submitted by a ring wizard
      :issued     # Issued by an admin
    )

    log_changes if respond_to?(:log_changes)

    # This ring is charged to an owner
    belongs_to :owner, polymorphic: true

    # This could be a RingWizard, or Blank (admin created)
    belongs_to :parent, polymorphic: true, optional: true

    effective_resource do
      size               :integer
      metal              :string

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

    validates :metal, presence: true, inclusion: { in: METALS }

    validates :size, presence: true
    validates :size, inclusion: { in: TITANIUM_SIZES }, if: -> { metal == 'Titanium' }
    validates :size, inclusion: { in: SIZES }, if: -> { metal != 'Titanium' }

    validates :parent, presence: true, unless: -> { created_by_admin? }

    def to_s
      [
        model_name.human,
        ('Replacement' if parent_ring_wizard?),
        ("- #{metal} size #{size}" if metal.present? && size.present?)
      ].compact.join(' ')
    end

    def parent_ring_wizard?
      parent if parent_type.to_s.include?('RingWizard')
    end

    # Called by a ring wizard when submitted
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
