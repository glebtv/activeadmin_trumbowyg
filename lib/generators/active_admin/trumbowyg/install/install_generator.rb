# frozen_string_literal: true

require 'rails/generators'

module ActiveAdmin
  module Trumbowyg
    module Generators
      class InstallGenerator < Rails::Generators::Base
        source_root File.expand_path('templates', __dir__)

        desc 'Installs ActiveAdmin Trumbowyg for ActiveAdmin 4.x'

        class_option :bundler,
                     type: :string,
                     default: 'esbuild',
                     desc: 'JavaScript bundler to use (esbuild, importmap, webpack)',
                     enum: %w[esbuild importmap webpack]

        def install_npm_package
          return if options[:bundler] == 'importmap'

          say 'Installing @rocket-sensei/activeadmin_trumbowyg npm package...', :green
          run 'npm install @rocket-sensei/activeadmin_trumbowyg jquery trumbowyg'
        end

        def setup_javascript
          case options[:bundler]
          when 'esbuild'
            setup_esbuild
          when 'importmap'
            setup_importmap
          when 'webpack'
            setup_webpack
          end
        end

        def setup_stylesheets
          if File.exist?('app/assets/stylesheets/active_admin.css')
            say 'Adding Trumbowyg styles to active_admin.css...', :green
            append_to_file 'app/assets/stylesheets/active_admin.css' do
              <<~CSS

                /* Trumbowyg Editor */
                @import url('https://cdn.jsdelivr.net/npm/trumbowyg@2/dist/ui/trumbowyg.min.css');
              CSS
            end
          elsif File.exist?('app/assets/stylesheets/active_admin.scss')
            say 'Adding Trumbowyg styles to active_admin.scss...', :green
            append_to_file 'app/assets/stylesheets/active_admin.scss' do
              <<~SCSS

                // Trumbowyg Editor
                @import url('https://cdn.jsdelivr.net/npm/trumbowyg@2/dist/ui/trumbowyg.min.css');
              SCSS
            end
          else
            say 'Please manually add Trumbowyg styles to your ActiveAdmin stylesheet', :yellow
          end
        end

        def copy_icons
          say 'Icons are automatically included via the NPM package', :green
        end

        def show_post_install_message
          say "\n✅ ActiveAdmin Trumbowyg has been installed!", :green

          case options[:bundler]
          when 'esbuild'
            say "\nMake sure to rebuild your JavaScript:", :yellow
            say '  npm run build', :cyan
            say "\nFor development with watch mode:", :yellow
            say '  npm run build -- --watch', :cyan
          when 'importmap'
            say "\nRestart your Rails server to load the new pins.", :yellow
          when 'webpack'
            say "\nRecompile your webpack bundles:", :yellow
            say '  bin/webpack', :cyan
          end

          say "\n📚 Usage example:", :green
          say <<~RUBY

            # In your ActiveAdmin resource:
            ActiveAdmin.register Article do
              form do |f|
                f.inputs 'Article' do
                  f.input :title
                  f.input :description, as: :trumbowyg
                  f.input :published
                end
                f.actions
              end
            end

            # With custom options:
            f.input :description, as: :trumbowyg, input_html: {#{' '}
              data: {#{' '}
                options: {#{' '}
                  btns: [
                    ['bold', 'italic'],#{' '}
                    ['link'],
                    ['upload']
                  ],
                  plugins: {
                    upload: {
                      serverPath: upload_admin_article_path(resource.id),
                      fileFieldName: 'file_upload'
                    }
                  }
                }
              }
            }
          RUBY

          say "\n📦 Note: Icons and styles are included automatically.", :green
        end

        private

        def setup_esbuild
          say 'Setting up for esbuild...', :green

          js_file = 'app/javascript/active_admin.js'

          if File.exist?(js_file)
            say "Adding Trumbowyg to #{js_file}...", :green
            append_to_file js_file do
              <<~JS

                // ActiveAdmin Trumbowyg Editor
                // All dependencies and initialization are handled by the package
                import '@rocket-sensei/activeadmin_trumbowyg';
              JS
            end
          else
            say "Creating #{js_file}...", :green
            create_file js_file do
              <<~JS
                import "@activeadmin/activeadmin";

                // ActiveAdmin Trumbowyg Editor
                // All dependencies and initialization are handled by the package
                import '@rocket-sensei/activeadmin_trumbowyg';
              JS
            end
          end

          update_package_json_scripts
        end

        def setup_importmap
          say 'Setting up for importmap...', :green

          if File.exist?('config/importmap.rb')
            say 'Adding pins to config/importmap.rb...', :green
            append_to_file 'config/importmap.rb' do
              <<~RUBY

                # ActiveAdmin Trumbowyg Editor
                pin "jquery", to: "https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"
                pin "trumbowyg", to: "https://cdn.jsdelivr.net/npm/trumbowyg@2/dist/trumbowyg.min.js"
                pin "activeadmin_trumbowyg", to: "activeadmin-trumbowyg.js"
              RUBY
            end
          end

          js_file = 'app/javascript/application.js'
          return unless File.exist?(js_file)

          say "Adding import to #{js_file}...", :green
          append_to_file js_file do
            <<~JS

              // ActiveAdmin Trumbowyg Editor - single import loads everything
              import "activeadmin_trumbowyg"
            JS
          end
        end

        def setup_webpack
          say 'Setting up for webpack...', :green

          js_file = 'app/javascript/packs/active_admin.js'

          if File.exist?(js_file)
            say "Adding Trumbowyg to #{js_file}...", :green
            append_to_file js_file do
              <<~JS

                // ActiveAdmin Trumbowyg Editor - single import loads everything
                import '@rocket-sensei/activeadmin_trumbowyg';
              JS
            end
          else
            say 'Please manually add Trumbowyg import to your ActiveAdmin JavaScript pack', :yellow
            say "Add this line: import '@rocket-sensei/activeadmin_trumbowyg';", :cyan
          end
        end

        def update_package_json_scripts
          return unless File.exist?('package.json')

          package_json = JSON.parse(File.read('package.json'))
          return if package_json['scripts'] && package_json['scripts']['build']

          say 'Adding build script to package.json...', :green
          package_json['scripts'] ||= {}
          package_json['scripts']['build'] =
            'esbuild app/javascript/*.* --bundle --sourcemap --format=esm ' \
            '--outdir=app/assets/builds --public-path=/assets'

          File.write('package.json', JSON.pretty_generate(package_json))
        end
      end
    end
  end
end
