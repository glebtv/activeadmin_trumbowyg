# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activeadmin/trumbowyg/version'

Gem::Specification.new do |spec|
  spec.name          = 'activeadmin_trumbowyg'
  spec.version       = ActiveAdmin::Trumbowyg::VERSION
  spec.summary       = 'Trumbowyg Editor for ActiveAdmin'
  spec.description   = 'An Active Admin plugin to use Trumbowyg Editor'
  spec.license       = 'MIT'
  spec.authors       = ['Mattia Roccoberton']
  spec.email         = 'mat@blocknot.es'
  spec.homepage      = 'https://github.com/blocknotes/activeadmin_trumbowyg'

  spec.required_ruby_version = '>= 3.2'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['changelog_uri']   = 'https://github.com/blocknotes/activeadmin_trumbowyg/blob/main/CHANGELOG.md'
  spec.metadata['source_code_uri'] = spec.homepage

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files         = Dir['{app,lib}/**/*', 'LICENSE.txt', 'Rakefile', 'README.md']
  spec.require_paths = ['lib']

  spec.add_dependency 'activeadmin', '~> 4.0.0.beta'

  # Development dependencies
  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'capybara'
  spec.add_development_dependency 'capybara-playwright-driver'
  spec.add_development_dependency 'combustion'
  spec.add_development_dependency 'cuprite'
  spec.add_development_dependency 'database_cleaner-active_record'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'simplecov'
  
  # Linters
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-capybara'
  spec.add_development_dependency 'rubocop-packaging'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rails'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'rubocop-rspec_rails'
  
  # Tools
  spec.add_development_dependency 'pry-rails'
end
