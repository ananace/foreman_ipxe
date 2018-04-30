module ForemanIpxe
  class Engine < ::Rails::Engine
    engine_name 'foreman_ipxe'

    initializer 'foreman_ipxe.register_plugin', before: :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_ipxe do
        requires_foreman '>= 1.14'
      end
    end

    config.to_prepare do
      begin
        ::Operatingsystem.send :include, ForemanIpxe::OperatingsystemExtensions
        ::UnattendedController.send :prepend, ForemanIpxe::UnattendedControllerExtensions
        ::TemplateKind.send :prepend, ForemanIpxe::TemplateKindExtensions
      rescue => e
        Rails.logger.warn "ForemanIpxe: skipping engine hook(#{e})"
      end
    end
  end
end
