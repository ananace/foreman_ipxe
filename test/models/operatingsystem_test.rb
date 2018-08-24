# frozen_string_literal: true

require 'test_plugin_helper'

class OperatingsystemTest < ActiveSupport::TestCase
  describe '#all_loaders_map' do
    test 'should include ipxe loaders' do
      assert_includes Operatingsystem.all_loaders_map.keys, 'iPXE Chain BIOS'
      assert_includes Operatingsystem.all_loaders_map.keys, 'iPXE Chain UEFI'
      assert_includes Operatingsystem.all_loaders_map.keys, 'iPXE'
    end
  end

  describe '#boot_filename' do
    test 'should be the ipxe unattended url for iPXE' do
      host = FactoryBot.build(:host, :managed, pxe_loader: 'iPXE')
      assert_equal 'http://foreman.some.host.fqdn/unattended/iPXE', Operatingsystem.boot_filename(host)
    end
  end
end
