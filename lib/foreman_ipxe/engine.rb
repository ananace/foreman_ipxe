module ForemanIpxe
  class Engine < ::Rails::Engine
    engine_name 'foreman_ipxe'

    initializer 'foreman_ipxe.load_default_settings', before: :load_config_initializers do
      require_dependency File.expand_path('../../app/models/setting/ipxe.rb', __dir__) if (Setting.table_exists? rescue(false))
    end

    initializer 'foreman_ipxe.register_plugin', before: :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_ipxe do
        requires_foreman '>= 1.18'
      end
    end

    config.to_prepare do
      begin
        ::Operatingsystem.send(:include, ForemanIpxe::OperatingsystemExtensions)
        ::UnattendedController.send(:include, ForemanIpxe::UnattendedControllerExtensions)
      rescue => e
        Rails.logger.warn "ForemanIpxe: skipping engine hook(#{e})"
      end
    end
  end
end
