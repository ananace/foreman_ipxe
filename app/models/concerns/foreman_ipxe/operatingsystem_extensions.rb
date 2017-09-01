module ForemanIpxe
  module OperatingsystemExtensions
    extend ActiveSupport::Concern

    included do
      Rails.logger.warn("OS included! #{self}")

      # alias_method_chain :all_loaders_map, :ipxe
    end

    module ClassMethods
      def all_loaders_map(arch = 'x64')
        super(arch)
          .merge('iPXE BIOS' => 'undionly.kpxe', 'iPXE UEFI' => 'ipxe.efi')
          .freeze
      end
    end
  end
end
