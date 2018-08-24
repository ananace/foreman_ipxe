# frozen_string_literal: true

class Setting
  class Ipxe < ::Setting
    def self.load_defaults
      return unless ActiveRecord::Base.connection.table_exists?('settings')
      return unless super

      templates = proc { Hash[ProvisioningTemplate.unscoped.of_kind('iPXE').map { |tmpl| [tmpl.name, tmpl.name] }] }

      Setting.transaction do
        [
          set('global_iPXE', N_('Global default iPXE template.'), ProvisioningTemplate.global_default_name('iPXE'), N_('Global default iPXE template'), nil, collection: templates),
          set('local_boot_iPXE', N_('Template that will be selected as iPXE default for local boot.'), ProvisioningTemplate.local_boot_name('iPXE'), N_('Local boot iPXE template'), nil, collection: templates)
        ].compact.each { |s| Setting::Provisioning.create s.update(category: 'Setting::Provisioning') }
      end

      true
    end

    def self.humanized_category
      N_('iPXE')
    end
  end
end
