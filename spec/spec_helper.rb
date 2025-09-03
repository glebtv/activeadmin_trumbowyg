# frozen_string_literal: true

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
