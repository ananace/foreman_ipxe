module ForemanIpxe
  module PxeLoaderSupportExtensions
    extend ActiveSupport::Concern

    included do
      Rails.logger.warn("PxeExtensions included! #{self}")
      # alias_method_chain :all_loaders_map, :ipxe
    end
  end
end
