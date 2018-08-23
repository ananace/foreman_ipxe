# frozen_string_literal: true

module ForemanIpxe
  module OperatingsystemExtensions
    extend ActiveSupport::Concern

    module ClassMethods
      def all_loaders_map(arch = 'x64')
        super(arch)
          .merge('iPXE Chain BIOS' => 'undionly.kpxe', 'iPXE Chain UEFI' => 'ipxe.efi', 'iPXE' => nil)
          .freeze
      end

      def boot_filename(host = nil)
        return host.foreman_url('iPXE') if host.pxe_loader == 'iPXE'
        super(host)
      end
    end
  end
end
