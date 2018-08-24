# frozen_string_literal: true

require "#{File.expand_path('lib', __dir__)}/foreman_ipxe/version"

Gem::Specification.new do |spec|
  spec.name          = 'foreman_ipxe'
  spec.version       = ForemanIpxe::VERSION
  spec.authors       = ['Alexander Olofsson']
  spec.email         = ['alexander.olofsson@liu.se']

  spec.summary       = 'Adds chainloaded iPXE loaders'
  spec.description   = 'Allows provisioning iPXE with chainloaded iPXE binaries'
  spec.homepage      = 'https://github.com/ananace/foreman_ipxe'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rdoc'
  spec.add_development_dependency 'rubocop', '0.52.1'
end
