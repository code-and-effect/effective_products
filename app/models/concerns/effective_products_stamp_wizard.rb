# frozen_string_literal: true

# EffectiveProductsStampWizard
#
# Mark your owner model with effective_products_stamp_wizard to get all the includes

module EffectiveProductsStampWizard
  extend ActiveSupport::Concern

  module Base
    def effective_products_stamp_wizard
      include ::EffectiveProductsStampWizard
    end
  end

  module ClassMethods
    def effective_products_stamp_wizard?; true; end
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
      stamp: 'Select Stamp',
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
    has_many :stamps, -> { order(:id) }, class_name: 'Effective::Stamp', inverse_of: :parent, dependent: :nullify
    accepts_nested_attributes_for :stamps, reject_if: :all_blank, allow_destroy: true

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

    scope :deep, -> { includes(:owner, :orders, :stamps) }
    scope :sorted, -> { order(:id) }

    scope :in_progress, -> { where.not(status: [:submitted]) }
    scope :done, -> { where(status: [:submitted]) }

    scope :for, -> (user) { where(owner: user) }

    before_validation(if: -> { current_step == :stamp && stamp.present? }) do
      assign_pricing unless stamp.purchased?
    end

    # All Steps validations
    validates :owner, presence: true

    # Stamp Step
    validate(if: -> { current_step == :stamp }) do
      errors.add(:stamps, "can't be blank") unless present_stamps.present?
    end

    # All Fees and Orders
    def submit_fees
      stamps
    end

    def after_submit_purchased!
      stamps.each { |stamp| stamp.submit! }
    end
  end

  # Instance Methods
  def to_s
    (persisted? || destroyed?) ? "#{model_name.human} ##{id_was}" : model_name.human
  end

  def stamp_categories
    EffectiveProducts.stamp_categories
  end

  def in_progress?
    draft?
  end

  def done?
    submitted?
  end

  def stamp
    stamps.first
  end

  def build_stamp
    stamps.build(
      owner: owner,
      name: owner.to_s.presence,
      shipping_address: (owner.try(:shipping_address) || owner.try(:billing_address)),
    )
  end

  def assign_pricing
    raise('assign_pricing() to be implemented by including class')

    # price = (stamp.physical? ? 100_00 : 50_00)
    # qb_item_name = "Professional Stamp"
    # tax_exempt = false

    # stamp.assign_attributes(price: price, qb_item_name: qb_item_name, tax_exempt: tax_exempt)
  end

  private

  def present_stamps
    stamps.reject(&:marked_for_destruction?)
  end

end
