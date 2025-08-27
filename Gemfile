# frozen_string_literal: true

source 'https://rubygems.org'

def eval_version(dependency, version)
  return [dependency] if version.empty?

  version.count('.') < 2 ? [dependency, "~> #{version}.0"] : [dependency, version]
end

if ENV['DEVEL'] == '1'
  gem 'activeadmin_trumbowyg', path: './'
else
  gemspec
end

ruby_ver = ENV.fetch('RUBY_VERSION', '')

rails_ver = ENV.fetch('RAILS_VERSION', '')
rails = eval_version('rails', rails_ver)
gem(*rails)

active_admin_ver = ENV.fetch('ACTIVEADMIN_VERSION', '')
active_admin = eval_version('activeadmin', active_admin_ver)
gem(*active_admin)

ruby32 = ruby_ver.empty? || Gem::Version.new(ruby_ver) >= Gem::Version.new('3.2')
rails72 = rails_ver.empty? || Gem::Version.new(rails_ver) >= Gem::Version.new('7.2')
sqlite3 = ruby32 && rails72 ? ['sqlite3'] : ['sqlite3', '~> 1.4']
gem(*sqlite3)

gem 'zeitwerk', '~> 2.6.18' unless ruby32

# NOTE: to avoid error: uninitialized constant ActiveSupport::LoggerThreadSafeLevel::Logger
gem 'concurrent-ruby', '1.3.4'

gem 'bigdecimal'
gem 'csv'
gem 'importmap-rails', '~> 2.0'
gem 'jquery-rails'
gem 'mutex_m'
gem 'puma'
gem 'propshaft'
gem 'tailwindcss-rails'

# Development dependencies (moved from gemspec per RuboCop best practices)
gem 'appraisal'
gem 'capybara'
gem 'capybara-playwright-driver'
gem 'combustion'
gem 'cuprite'
gem 'database_cleaner-active_record'
gem 'rspec_junit_formatter'
gem 'rspec-rails'
gem 'simplecov'

# Linters
gem 'rubocop'
gem 'rubocop-capybara'
gem 'rubocop-packaging'
gem 'rubocop-performance'
gem 'rubocop-rails'
gem 'rubocop-rspec'
gem 'rubocop-rspec_rails'

# Tools
gem 'fasterer'
gem 'pry-rails'
