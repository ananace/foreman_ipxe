# frozen_string_literal: true

module ForemanIpxe
  class IpxeStubRenderer
    attr_accessor :message

    def initialize(message: 'Deliberately empty iPXE template')
      @message = message
    end

    def to_s
      <<~MESSAGE
        #!ipxe
        # #{message}
        exit
      MESSAGE
    end
  end
end
