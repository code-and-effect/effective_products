# Dashboard Ring Payments
class EffectiveRingWizardsDatatable < Effective::Datatable
  datatable do
    order :created_at

    col :token, visible: false
    col :created_at, visible: false

    col(:submitted_at, label: 'Submitted on') do |resource|
      resource.submitted_at&.strftime('%F') || 'Incomplete'
    end

    col :owner, visible: false, search: :string
    col :status, visible: false
    col :orders, action: :show

    col(:issued_at, label: 'Issued on') do |resource|
      resource.ring&.issued_at&.strftime('%F') || '-'
    end

    actions_col(actions: []) do |resource|
      if resource.draft?
        dropdown_link_to('Continue', effective_products.ring_wizard_build_path(resource, resource.next_step), 'data-turbolinks' => false)
        dropdown_link_to('Delete', effective_products.ring_wizard_path(resource), 'data-confirm': "Really delete #{resource}?", 'data-method': :delete)
      else
        dropdown_link_to('Show', effective_products.ring_wizard_path(resource))
      end
    end

  end

  collection do
    EffectiveProducts.RingWizard.deep.where(owner: current_user)
  end

end
