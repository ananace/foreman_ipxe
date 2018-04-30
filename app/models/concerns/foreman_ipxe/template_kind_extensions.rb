module ForemanIpxe
  module TemplateKindExtensions
    def self.prepended(base)
      old_value = base.const_get(:PXE)
      base.send(:remove_const, :PXE)
      base.const_set(:PXE, old_value + ['iPXE'])
    end
  end
end
