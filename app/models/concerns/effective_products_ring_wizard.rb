# frozen_string_literal: true

# EffectiveProductsRingWizard
#
# Mark your owner model with effective_products_ring_wizard to get all the includes

module EffectiveProductsRingWizard
  extend ActiveSupport::Concern

  module Base
    def effective_products_ring_wizard
      include ::EffectiveProductsRingWizard
    end
  end

  module ClassMethods
    def effective_products_ring_wizard?; true; end
  end

  included do
    acts_as_purchasable_parent
    acts_as_tokened

    acts_as_statused(
      :draft,      # Just Started
      :submitted   # All done
    )

    acts_as_wizard(
      start: 'Start',
      ring: 'Select Ring',
      summary: 'Review',
      billing: 'Billing Address',
      checkout: 'Checkout',
      submitted: 'Submitted'
    )

    acts_as_purchasable_wizard

    log_changes(except: :wizard_steps) if respond_to?(:log_changes)

    # Application Namespace
    belongs_to :owner, polymorphic: true
    accepts_nested_attributes_for :owner

    # Effective Namespace
    has_many :rings, -> { order(:id) }, class_name: 'Effective::Ring', inverse_of: :ring_wizard, dependent: :destroy
    accepts_nested_attributes_for :rings, reject_if: :all_blank, allow_destroy: true

    has_many :orders, -> { order(:id) }, as: :parent, class_name: 'Effective::Order', dependent: :nullify
    accepts_nested_attributes_for :orders

    effective_resource do
      # Acts as Statused
      status                 :string, permitted: false
      status_steps           :text, permitted: false

      # Dates
      submitted_at           :datetime

      # Acts as Wizard
      wizard_steps           :text, permitted: false

      timestamps
    end

    scope :deep, -> { includes(:owner, :orders, :rings) }
    scope :sorted, -> { order(:id) }

    scope :in_progress, -> { where.not(status: [:submitted]) }
    scope :done, -> { where(status: [:submitted]) }

    scope :for, -> (user) { where(owner: user) }

    # All Steps validations
    validates :owner, presence: true

    # Tickets Step
    validate(if: -> { current_step == :ring }) do
      self.errors.add(:rings, "can't be blank") unless present_rings.present?
    end

    # All Fees and Orders
    def submit_fees
      rings
    end

    def after_submit_purchased!
      # Nothing to do yet
    end

  end

  # Instance Methods
  def to_s
    'ring payment'
  end

  def in_progress?
    draft?
  end

  def done?
    submitted?
  end

  def ring
    rings.first
  end

  def build_ring
    ring = rings.build(owner: owner)
    address = owner.try(:shipping_address) || owner.try(:billing_address)

    if address.present?
      ring.shipping_address = address
    end

    ring
  end

  def assign_pricing
    price = case ring.metal
      when '14k Yellow Gold' then 450_00
      when 'Sterling Silver' then 175_00
      when 'Titanium' then 50_00
      else
        raise "unexpected ring metal: #{ring.metal || 'none'}"
      end

    qb_item_name = "Chemist's Ring"
    tax_exempt = false

    ring.assign_attributes(price: price, qb_item_name: qb_item_name, tax_exempt: tax_exempt)
  end

  # After the configure Ring step
  def ring!
    assign_pricing() if ring.present?
    save!
  end

  private

  def present_rings
    rings.reject(&:marked_for_destruction?)
  end

end
