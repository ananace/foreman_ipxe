# frozen_string_literal: true

require 'test_plugin_helper'

class UnattendedControllerTest < ActionController::TestCase
  let(:tax_organization) do
    FactoryBot.create(
      :organization,
      ignore_types: ['ProvisioningTemplate']
    )
  end
  let(:tax_location) do
    FactoryBot.create(
      :location,
      ignore_types: ['ProvisioningTemplate']
    )
  end
  let(:ipxe_kind) { TemplateKind.find_by(name: 'iPXE') }
  let(:ipxe_template) do
    FactoryBot.create(
      :provisioning_template,
      template_kind: ipxe_kind,
      name: 'iPXE test template',
      template: "#!ipxe\necho Test build\nexit",
      organizations: [tax_organization],
      locations: [tax_location]
    )
  end
  let(:operatingsystem) do
    FactoryBot.create(
      :operatingsystem,
      :with_associations,
      :with_os_defaults,
      family: 'Redhat',
      provisioning_templates: [ipxe_template]
    )
  end
  let(:host) do
    FactoryBot.create(
      :host,
      :managed,
      operatingsystem: operatingsystem,
      organization: tax_organization,
      location: tax_location
    )
  end

  setup do
    disable_orchestration
    operatingsystem.provisioning_templates << ipxe_template
  end

  context 'without a host' do
    test 'should render iPXE error when global iPXE template is not found' do
      get :host_template, params: { kind: 'iPXE' }, session: set_session_user
      assert_response :not_found
      assert_includes @response.body, "Global iPXE template 'iPXE global default' not found"
    end

    test 'should render global iPXE template' do
      FactoryBot.create(
        :provisioning_template,
        template_kind: ipxe_kind,
        name: 'iPXE global default',
        template: "#!ipxe\necho Test global\nexit"
      )
      get :host_template, params: { kind: 'iPXE' }, session: set_session_user
      assert_response :success
      assert_includes @response.body, 'Test global'
    end
  end

  context 'with a host' do
    test 'should render a fallback ipxe template' do
      get :host_template, params: { kind: 'iPXE', mac: host.mac }, session: set_session_user
      assert_response :success
      assert_includes @response.body, 'iPXE default local boot fallback'
    end

    test 'should render the ipxe local template' do
      FactoryBot.create(
        :provisioning_template,
        template_kind: ipxe_kind,
        name: 'iPXE default local boot',
        template: "#!ipxe\necho Test local\nexit"
      )
      get :host_template, params: { kind: 'iPXE', mac: host.mac }, session: set_session_user
      assert_response :success
      assert_includes @response.body, 'Test local'
    end
  end

  context 'with a host in build mode' do
    let(:ipxe_parameter_template) do
      FactoryBot.create(
        :provisioning_template,
        template_kind: ipxe_kind,
        name: 'iPXE parameter template',
        template: "#!ipxe\necho Test parameter\nexit"
      )
    end

    setup do
      host.update(build: true)
    end

    test 'should render the associated ipxe template' do
      get :host_template, params: { kind: 'iPXE', mac: host.mac }, session: set_session_user
      assert_response :success
      assert_includes @response.body, 'Test build'
    end

    test 'should render the template specified as host parameter' do
      FactoryBot.create(
        :host_parameter,
        host: host,
        name: 'iPXE_Template',
        value: ipxe_parameter_template.name
      )

      assert_not_nil host.host_params['iPXE_Template']

      get :host_template, params: { kind: 'iPXE', mac: host.mac }, session: set_session_user
      assert_response :success
      assert_includes @response.body, 'Test parameter'
    end

    test 'should render an error if the template specified as host parameter is not found' do
      FactoryBot.create(
        :host_parameter,
        host: host,
        name: 'iPXE_Template',
        value: 'iPXE parameter template'
      )

      assert_not_nil host.host_params['iPXE_Template']

      get :host_template, params: { kind: 'iPXE', mac: host.mac }, session: set_session_user
      assert_response :not_found
      assert_includes @response.body, 'iPXE parameter template'
    end
  end
end
