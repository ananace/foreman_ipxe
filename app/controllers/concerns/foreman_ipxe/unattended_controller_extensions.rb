module ForemanIpxe
  module UnattendedControllerExtensions
    IPXE_TEMPLATE_PARAMETER = 'iPXE_Template'.freeze

    def self.prepended(base)
      base.skip_before_action :get_host_details, if: proc { %w[iPXE gPXE].include? params[:kind] }
      base.skip_before_action :allowed_to_install?, if: proc { %w[iPXE gPXE].include? params[:kind] }
      base.skip_before_action :load_template_vars, if: proc { %w[iPXE gPXE].include? params[:kind] }
    end

    def render_template(type)
      @host = find_host_by_spoof || find_host_by_token || find_host_by_ip_or_mac
      if %w[iPXE gPXE].include?(type)
        if !@host && !@host.provisioning_template(kind: 'iPXE')
          name = ProvisioningTemplate.global_template_name_for('iPXE', self)
          config = ProvisioningTemplate.find_by_name name

          unless config
            return render(plain: "#!ipxe\n\necho " + (_("Global iPXE template '%s' not found") % name) + "\nshell\n", status: :not_found, :content_type => 'text/plain')
          end
        elsif @host && !@host.build?
          name = Setting[:local_boot_iPXE] || ProvisioningTemplate.local_boot_name(:iPXE)
          config = ProvisioningTemplate.find_by_name name
          config ||= ProvisioningTemplate.new name: 'iPXE default local boot fallback',
                                              template: "#!ipxe\n# iPXE default local boot fallback\n\nexit\n"
        elsif @host && @host.parameters.where(name: IPXE_TEMPLATE_PARAMETER).any?
          name = @host.parameters.find_by name: IPXE_TEMPLATE_PARAMETER
          config = ProvisioningTemplate.find_by name: name
        end

        return safe_render config if config

        return unless verify_found_host(@host)
        return unless allowed_to_install?
        return unless load_template_vars
      end

      super(type)
    end
  end
end
