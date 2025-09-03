# frozen_string_literal: true

# SimpleCov configuration for code coverage
# Must be started before any application code is loaded
require 'simplecov'
require 'simplecov_json_formatter'

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
                                                                  SimpleCov::Formatter::HTMLFormatter,
                                                                  SimpleCov::Formatter::JSONFormatter
                                                                ])

SimpleCov.start do
  # Add filters to exclude non-application code
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'
  add_filter '/spec/internal/'
  add_filter '/.bundle/'

  # Group files for better organization in the coverage report
  add_group 'Library', 'lib/'
  add_group 'Generators', 'lib/generators/'
  add_group 'Inputs', 'lib/formtastic/'
  add_group 'Source', 'src/'

  # Set the coverage output directory
  coverage_dir 'coverage'

  # Track all files, including those not loaded during tests
  track_files 'lib/**/*.rb'

  # Set minimum coverage threshold (optional)
  # TODO: Increase this threshold as test coverage improves
  minimum_coverage 4
end

RSpec.configure do |config|
  # IMPORTANT: Exclude vendor and node_modules paths from spec discovery
  # This prevents RSpec from loading specs from symlinked npm packages
  # Must be set BEFORE other configurations
  config.exclude_pattern = '**/vendor/**/*_spec.rb,**/node_modules/**/*_spec.rb'

  config.disable_monkey_patching!
  config.filter_run focus: true
  config.filter_run_excluding changes_filesystem: true
  config.run_all_when_everything_filtered = true

  config.color = true
  config.tty = true

  config.example_status_persistence_file_path = '.rspec_failures'
  config.order = :random
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
