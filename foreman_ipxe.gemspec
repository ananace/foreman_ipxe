# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'foreman_ipxe/version'

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

  spec.add_development_dependency 'bundler', '>= 1.13'
  spec.add_development_dependency 'minitest', '>= 5.0'
  spec.add_development_dependency 'rake', '>= 10.0'
end
