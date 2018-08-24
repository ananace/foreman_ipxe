# frozen_string_literal: true

module ForemanIpxe
  class IpxeMessageRenderer
    attr_accessor :message

    def initialize(message: nil)
      @message = message
    end

    def to_s
      <<~MESSAGE
        #!ipxe
        echo #{message}
        shell
      MESSAGE
    end
  end
end
