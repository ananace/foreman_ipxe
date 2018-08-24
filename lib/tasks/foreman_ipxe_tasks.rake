# frozen_string_literal: true

require 'rake/testtask'

# Tests
namespace :test do
  desc 'Test ForemanIpxe'
  Rake::TestTask.new(:foreman_ipxe) do |t|
    test_dir = File.join(File.dirname(__FILE__), '../..', 'test')
    t.libs << ['test', test_dir]
    t.pattern = "#{test_dir}/**/*_test.rb"
    t.verbose = true
    t.warning = false
  end
end

namespace :foreman_ipxe do
  task :rubocop do
    begin
      require 'rubocop/rake_task'
      RuboCop::RakeTask.new(:rubocop_foreman_ipxe) do |task|
        task.patterns = ["#{ForemanIpxe::Engine.root}/app/**/*.rb",
                         "#{ForemanIpxe::Engine.root}/lib/**/*.rb",
                         "#{ForemanIpxe::Engine.root}/test/**/*.rb"]
      end
    rescue StandardError
      puts 'Rubocop not loaded.'
    end

    Rake::Task['rubocop_foreman_ipxe'].invoke
  end
end

Rake::Task[:test].enhance ['test:foreman_ipxe']

load 'tasks/jenkins.rake'
Rake::Task['jenkins:unit'].enhance ['test:foreman_ipxe', 'foreman_ipxe:rubocop'] if Rake::Task.task_defined?(:'jenkins:unit')
