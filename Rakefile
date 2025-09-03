# frozen_string_literal: true

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

APP_RAKEFILE = File.expand_path("spec/internal/Rakefile", __dir__)
load 'rails/tasks/engine.rake' if File.exist?(APP_RAKEFILE)

# load 'rails/tasks/statistics.rake' # Commented out - causes issues with Rails 8

require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec) do |t|
    # t.ruby_opts = %w[-w]
    t.rspec_opts = ['--color', '--format documentation']
  end

  task default: :spec
rescue LoadError
  puts '! LoadError: no RSpec available'
end
