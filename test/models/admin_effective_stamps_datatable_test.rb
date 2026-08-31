require 'test_helper'

class AdminEffectiveStampsDatatableTest < ActiveSupport::TestCase
  test 'parent column does not display the parent status badge' do
    datatable = Admin::EffectiveStampsDatatable.new.rendered(current_user: User.new)

    assert_equal false, datatable.columns[:parent][:badge]
  end

  test 'current and applicant categories follow user and applicant' do
    datatable = Admin::EffectiveStampsDatatable.new.rendered(current_user: User.new)
    columns = datatable.columns.keys
    compute = datatable.columns[:current_category][:compute]

    assert_equal columns.index(:owner) + 1, columns.index(:current_category)
    assert_equal columns.index(:current_category) + 1, columns.index(:applicant_category)
    assert_nil compute.call(Effective::Stamp.new(owner: User.new))

    category = Struct.new(:name) { def to_s; name; end }.new('Registered')
    membership = Struct.new(:categories).new([category])
    owner = Struct.new(:membership).new(membership)

    assert_equal ['Registered'], compute.call(Struct.new(:owner).new(owner))

    applicant = Struct.new(:category).new(category)
    stamp = Effective::Stamp.new
    stamp.define_singleton_method(:applicant_categories) { [applicant.category.to_s] }
    applicant_compute = datatable.columns[:applicant_category][:compute]

    assert_equal ['Registered'], applicant_compute.call(stamp)
  end

  test 'applicant status follows parent and uses normal pagination' do
    datatable = Admin::EffectiveStampsDatatable.new.rendered(current_user: User.new)
    columns = datatable.columns.keys

    assert_equal columns.index(:applicant_category) + 1, columns.index(:applicant_status)
    assert_equal columns.index(:applicant_status) + 1, columns.index(:parent)
    assert_equal EffectiveDatatables.default_length, datatable.display_length
    assert_equal false, datatable.columns[:applicant_status][:sort]
  end
end
