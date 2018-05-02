module ForemanIpxe
  module UnattendedControllerExtensions
    def self.prepended(base)
      base.skip_before_action :get_host_details, if: proc { params[:kind] == 'iPXE' }
      base.skip_before_action :allowed_to_install?, if: proc { params[:kind] == 'iPXE' }
      base.skip_before_action :load_template_vars, if: proc { params[:kind] == 'iPXE' }
    end

    def render_template(type)
      @host = find_host_by_spoof || find_host_by_token || find_host_by_ip_or_mac
      if %w[iPXE gPXE].include?(type)
        if (!@host || !@host.provisioning_template(kind: 'iPXE'))
          config = ProvisioningTemplate.find_by_name(Setting[:global_iPXE] || 'iPXE Global Default')

          if config
            safe_render config
            return
          end
        end

        return unless verify_found_host(@host)
        return unless allowed_to_install?
        return unless load_template_vars
      end

      super(type)
    end
  end
end
