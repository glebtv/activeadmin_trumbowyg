# frozen_string_literal: true

# Debug monkey patch to understand what files RSpec is finding
# This helps debug why CI finds specs in node_modules but local doesn't

if ENV['DEBUG_RSPEC_FILES'] || ENV['CI']
  module RSpec
    module Core
      class Configuration
        # Monkey patch the get_files_to_run method to debug what files are found
        alias original_get_files_to_run get_files_to_run

        def get_files_to_run(paths)
          puts "\n#{'=' * 80}"
          puts "DEBUG: RSpec file discovery"
          puts "=" * 80
          puts "Paths to check: #{paths.inspect}"
          puts "Pattern: #{pattern}"
          puts "Exclude pattern: #{exclude_pattern}"
          puts "Current directory: #{Dir.pwd}"

          files = original_get_files_to_run(paths)

          puts "\nFound #{files.length} spec files:"

          # Separate files by category
          good_files = []
          node_modules_files = []
          vendor_files = []

          files.each do |file|
            if file.include?('node_modules')
              node_modules_files << file
              puts "  ⚠️  #{file} (IN NODE_MODULES!)"
            elsif file.include?('vendor')
              vendor_files << file
              puts "  ⚠️  #{file} (IN VENDOR!)"
            else
              good_files << file
              puts "  ✓ #{file}"
            end
          end

          if node_modules_files.any? || vendor_files.any?
            puts "\n⚠️  WARNING: Found specs in excluded directories:"
            puts "  - node_modules: #{node_modules_files.length} files"
            puts "  - vendor: #{vendor_files.length} files"
            puts "\n  This may cause issues when these files are loaded!"
          end

          # Group by directory for analysis
          by_dir = files.group_by { |f| File.dirname(f).split('/').first(5).join('/') }

          puts "\nFiles by directory:"
          by_dir.each do |dir, dir_files|
            puts "  #{dir}: #{dir_files.length} files"
          end

          puts "#{'=' * 80}\n"

          files
        end

        # Also debug the gather_directories method
        alias original_gather_directories gather_directories

        def gather_directories(path)
          include_files = get_matching_files(path, pattern)
          exclude_files = get_matching_files(path, exclude_pattern)

          if ENV['DEBUG_RSPEC_VERBOSE']
            puts "\nDEBUG gather_directories for path: #{path}"
            puts "  Include pattern: #{pattern}"
            puts "  Found #{include_files.length} files to include"
            puts "  Exclude pattern: #{exclude_pattern}"
            puts "  Found #{exclude_files.length} files to exclude"

            if include_files.any? { |f| f.include?('node_modules') }
              puts "  ⚠️  FOUND NODE_MODULES FILES!"
              include_files.select { |f| f.include?('node_modules') }.each do |f|
                puts "    - #{f}"
              end
            end
          end

          (include_files - exclude_files).uniq
        end
      end
    end
  end

  puts "DEBUG: RSpec file loading debug enabled"
end
