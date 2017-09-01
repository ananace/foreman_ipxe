module ForemanIpxe
  module OperatingsystemExtensions
    extend ActiveSupport::Concern

    module ClassMethods
      def all_loaders_map(arch = 'x64')
        super(arch)
          .merge('iPXE BIOS' => 'undionly.kpxe', 'iPXE UEFI' => 'ipxe.efi')
          .freeze
      end
    end
  end
end
