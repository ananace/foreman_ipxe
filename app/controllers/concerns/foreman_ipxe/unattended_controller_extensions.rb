module ForemanIpxe
  module UnattendedControllerExtensions
    def render_template(type)
      if (%w(iPXE gPXE).include?(type) && !host.provisioning_template(kind: 'iPXE'))
        config = ProvisioningTemplate.find_by_name(Setting[:global_iPXE])

        if config
          @kernel = host.operatingsystem.kernel(host.arch)
          @initrd = host.operatingsystem.initrd(host.arch)
          if host.operatingsystem.respond_to?(:mediumpath)
            @mediapath = host.operatingsystem.mediumpath(host)
          end
      
          if host.operatingsystem.respond_to?(:xen)
            @xen = host.operatingsystem.xen(host.arch)
          end
      
          @host = self.host

          return safe_render config
        end
      end

      super(type)
    end
  end
end
