namespace :active_admin do
  desc 'Build Active Admin Tailwind stylesheets'
  task :build do
    require 'fileutils'
    
    input = File.expand_path('../../spec/internal/app/assets/stylesheets/active_admin.css', __dir__)
    output = File.expand_path('../../spec/internal/app/assets/builds/active_admin.css', __dir__)
    config = File.expand_path('../../spec/internal/config/tailwind-active_admin.config.js', __dir__)
    
    # Ensure output directory exists
    FileUtils.mkdir_p(File.dirname(output))
    
    command = [
      'bundle', 'exec', 'tailwindcss',
      '-i', input,
      '-o', output,
      '-c', config,
      '-m'
    ]
    puts "Building Tailwind CSS: #{command.join(' ')}"

    system(*command, exception: true)
    puts "Tailwind CSS build complete: #{output}"
  end

  desc 'Watch Active Admin Tailwind stylesheets'
  task :watch do
    input = File.expand_path('../../spec/internal/app/assets/stylesheets/active_admin.css', __dir__)
    output = File.expand_path('../../spec/internal/app/assets/builds/active_admin.css', __dir__)
    config = File.expand_path('../../spec/internal/config/tailwind-active_admin.config.js', __dir__)
    
    command = [
      'bundle', 'exec', 'tailwindcss',
      '--watch',
      '-i', input,
      '-o', output,
      '-c', config,
      '-m'
    ]
    puts "Watching Tailwind CSS: #{command.join(' ')}"

    system(*command)
  end
end

Rake::Task['assets:precompile'].enhance(['active_admin:build']) if Rake::Task.task_defined?('assets:precompile')

Rake::Task['test:prepare'].enhance(['active_admin:build']) if Rake::Task.task_defined?('test:prepare')
Rake::Task['spec:prepare'].enhance(['active_admin:build']) if Rake::Task.task_defined?('spec:prepare')
Rake::Task['db:test:prepare'].enhance(['active_admin:build']) if Rake::Task.task_defined?('db:test:prepare')