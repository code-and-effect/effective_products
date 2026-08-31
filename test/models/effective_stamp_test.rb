require 'test_helper'

class EffectiveStampTest < ActiveSupport::TestCase
  test 'applicant status uses a direct applicant parent' do
    parent = Struct.new(:status, :category) do
      def self.effective_memberships_applicant?; true; end
    end.new('registered', 'P. Biol.')

    stamp = Effective::Stamp.new
    stamp.define_singleton_method(:parent) { parent }

    assert_equal 'Registered', stamp.applicant_status
    assert_equal 'P. Biol.', stamp.applicant_category
  end

  test 'applicant status uses fee payment registration applicants' do
    applicants = [
      Struct.new(:status, :category).new('registered', 'P. Biol.'),
      Struct.new(:status, :category).new('registered', 'P. Biol.')
    ]
    parent = Struct.new(:registration_applicants).new(applicants)

    stamp = Effective::Stamp.new
    stamp.define_singleton_method(:parent) { parent }

    assert_equal 'Registered', stamp.applicant_status
    assert_equal 'P. Biol.', stamp.applicant_category
  end

  test 'applicant status is blank for a stamp replacement' do
    stamp = Effective::Stamp.new
    stamp.define_singleton_method(:parent) { Struct.new(:status).new('submitted') }

    assert_nil stamp.applicant_status
    assert_nil stamp.applicant_category
  end
end
