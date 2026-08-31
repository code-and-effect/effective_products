require 'test_helper'

class AdminStampsStampPartialTest < ActionView::TestCase
  test 'shows the stamp form fields and datatable details' do
    user = build_user
    user.define_singleton_method(:shipping_address) { nil }

    stamp = Effective::Stamp.new(
      owner: user,
      name: 'Test User',
      name_confirmation: 'Test User',
      category: EffectiveProducts.stamp_categories.first
    )

    authorization_method = EffectiveResources.authorization_method
    begin
      EffectiveResources.authorization_method = true
      render partial: 'admin/stamps/stamp', locals: { stamp: stamp }
    ensure
      EffectiveResources.authorization_method = authorization_method
    end

    assert_select '.row-owner'
    assert_select '.row-name'
    assert_select '.row-shipping_address'
    assert_select '.row-status'
    assert_select '.row-current_category'
    assert_select '.row-applicant_category'
    assert_select '.row-applicant_status'
    assert_select '.row-purchased_order'
    assert_select '.row-qb_item_name'
  end
end
