# frozen_string_literal: true

namespace :app do
  namespace :active_admin do
    desc 'Build Active Admin Tailwind stylesheets for our app'
    task build: :environment do
      command = [
        Rails.root.join('bin/tailwindcss').to_s,
        '-i', Rails.root.join('app/assets/stylesheets/active_admin.css').to_s,
        '-o', Rails.root.join('app/assets/builds/active_admin.css').to_s,
        '-c', Rails.root.join('config/tailwind-active_admin.config.js').to_s,
        '-m'
      ]
      puts "Building Tailwind CSS: #{command.join(' ')}"

      system(*command, exception: true)
    end

    desc 'Watch Active Admin Tailwind stylesheets for our app'
    task watch: :environment do
      command = [
        Rails.root.join('bin/tailwindcss').to_s,
        '--watch',
        '-i', Rails.root.join('app/assets/stylesheets/active_admin.css').to_s,
        '-o', Rails.root.join('app/assets/builds/active_admin.css').to_s,
        '-c', Rails.root.join('config/tailwind-active_admin.config.js').to_s,
        '-m'
      ]
      puts command.join(' ')

      system(*command)
    end
  end
end

# Hook our app's build task to run before tests
Rake::Task['test:prepare'].enhance(['app:active_admin:build']) if Rake::Task.task_defined?('test:prepare')
Rake::Task['spec:prepare'].enhance(['app:active_admin:build']) if Rake::Task.task_defined?('spec:prepare')
Rake::Task['db:test:prepare'].enhance(['app:active_admin:build']) if Rake::Task.task_defined?('db:test:prepare')