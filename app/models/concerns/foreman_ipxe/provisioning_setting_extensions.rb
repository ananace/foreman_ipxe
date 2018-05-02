module ForemanIpxe
  module ProvisioningSettingExtensions
    module ClassMethods
      def default_global_labels
        super + ['global_iPXE']
      end

      def local_boot_labels
        super + ['local_boot_iPXE']
      end

      def map_pxe_kind
        ret = super
        ret << yield('iPXE', proc { Hash[ProvisioningTemplate.unscoped.of_kind('iPXE').map { |tmpl| [tmpl.name, tmpl.name] }] })
        ret
      end
    end

    def self.prepended(base)
      class << base
        prepend ClassMethods
      end
    end
  end
end
