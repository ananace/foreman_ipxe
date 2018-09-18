# frozen_string_literal: true

module ForemanIpxe
  module UnattendedControllerExtensions
    extend ActiveSupport::Concern

    IPXE_TEMPLATE_PARAMETER = 'iPXE_Template'

    module Overrides
      def render_template(type)
        return super(type) unless ipxe_request?(type)

        @host ||= find_host_by_spoof || find_host_by_token || find_host_by_ip_or_mac

        ipxe_template_kind = TemplateKind.find_by(name: 'iPXE')

        # rubocop:disable Style/SafeNavigation
        if !@host
          name = ProvisioningTemplate.global_template_name_for('iPXE', self)
          template = ProvisioningTemplate.find_global_default_template(name, 'iPXE')

          unless template
            render_ipxe_message(message: _("Global iPXE template '%s' not found") % name)
            return
          end
        elsif @host && !@host.build?
          return unless verify_found_host

          name = Setting[:local_boot_iPXE] || ProvisioningTemplate.local_boot_name(:iPXE)
          template = ProvisioningTemplate.find_by(name: name, template_kind: ipxe_template_kind)
          template ||= ProvisioningTemplate.new(
            name: 'iPXE default local boot fallback',
            template: ForemanIpxe::IpxeStubRenderer.new(
              message: 'iPXE default local boot fallback'
            ).to_s
          )
        elsif @host && @host.host_params[IPXE_TEMPLATE_PARAMETER]
          name = @host.host_params[IPXE_TEMPLATE_PARAMETER]
          template = ProvisioningTemplate.find_by(name: name, template_kind: ipxe_template_kind)

          unless template
            render_ipxe_message(message: _("iPXE template '%s' specified via a host parameter not found") % name)
            return
          end
        end
        # rubocop:enable Style/SafeNavigation

        return safe_render(template) if template

        return unless verify_found_host
        return unless allowed_to_install?
        load_template_vars

        super
      end

      def verify_found_host
        return false if host_not_found?(@host) || host_os_is_missing?(@host) || host_os_family_is_missing?(@host)
        logger.debug "Found #{@host}"
        true
      end
    end

    included do
      prepend Overrides

      skip_before_action :get_host_details, if: -> { ipxe_request?(params[:kind]) }
      skip_before_action :allowed_to_install?, if: -> { ipxe_request?(params[:kind]) }
      skip_before_action :load_template_vars, if: -> { ipxe_request?(params[:kind]) }
    end

    private

    def ipxe_request?(type)
      %w[iPXE gPXE].include?(type)
    end

    def render_ipxe_message(message: _('An error occured.'), status: :not_found)
      render(plain: ForemanIpxe::IpxeMessageRenderer.new(message: message).to_s, status: status, content_type: 'text/plain')
    end
  end
end
