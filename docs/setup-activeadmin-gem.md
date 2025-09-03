# Setting Up ActiveAdmin 4 Extension Gem with Combustion

This guide shows how to set up a new Rails gem for ActiveAdmin 4 with Combustion testing, exactly as configured in the working activeadmin_trumbowyg gem.

## CRITICAL: JavaScript Architecture for Gem Distribution

**Your gem's JavaScript code must live in the gem, NOT be copied to user apps!**

✅ **Correct approach:**
- Main JS module in `app/assets/javascripts/your_gem.js`
- Generator adds single import: `import 'your_gem_name'`
- Users get updates when they update your gem
- Code is maintainable and reusable

❌ **Wrong approach:**
- Generator copies large code blocks to user's app
- Users never get updates without re-running generator
- Code duplication across all installations
- Maintenance nightmare

## 1. Create Gem Structure

```bash
# Create new gem
bundle gem activeadmin_your_feature --test=rspec
cd activeadmin_your_feature
```

## 2. Update Gemspec

```ruby
# activeadmin_your_feature.gemspec
Gem::Specification.new do |spec|
  spec.name = "activeadmin_your_feature"
  # ... other standard fields ...
  
  spec.required_ruby_version = ">= 3.2"
  
  # Runtime dependencies
  spec.add_runtime_dependency "activeadmin", [">= 1.0", "< 5"]
  
  # Development dependencies
  spec.add_development_dependency "combustion", "~> 1.3"
  spec.add_development_dependency "rspec-rails", "~> 6.0"
  spec.add_development_dependency "capybara", "~> 3.39"
  spec.add_development_dependency "importmap-rails", "~> 2.0"
  spec.add_development_dependency "propshaft"  # Required - Sprockets not supported
end
```

## 3. Set Up Gemfile

```ruby
# Gemfile
source "https://rubygems.org"
gemspec

gem "rails", "~> 7.2"
gem "activeadmin", "~> 4.0.0.beta16"
gem "sqlite3"
gem "puma"

# Required for ActiveAdmin 4
gem "importmap-rails", "~> 2.0"
gem "propshaft"  # Required - Sprockets not supported

group :development, :test do
  gem "combustion", "~> 1.3"
  gem "rspec-rails"
  gem "capybara"
end
```

## 4. Generate Combustion Test App

```bash
# This creates spec/internal directory
bundle exec combust
```

## 5. Configure config.ru (CRITICAL LOADING ORDER!)

```ruby
# config.ru
require "rubygems"
require "bundler"

# DON'T use Bundler.require - loads gems too early!
Bundler.setup(:default, :development)

# Load Rails and combustion first
require 'combustion'

# Initialize Combustion with Rails components
Combustion.initialize! :active_record, :action_controller, :action_view do
  config.load_defaults Rails::VERSION::STRING.to_f if Rails::VERSION::MAJOR >= 7
end

# NOW load ActiveAdmin and dependencies after Rails is initialized
require 'importmap-rails'
require 'active_admin'
require 'activeadmin_your_feature'

# If you have custom Formtastic inputs
# require 'formtastic/inputs/your_input'

run Combustion::Application
```

## 6. Set Up Test App Structure

```bash
cd spec/internal

# Create necessary directories
mkdir -p app/admin
mkdir -p app/assets/{builds,config,stylesheets,javascripts}
mkdir -p app/js
mkdir -p app/models
mkdir -p config/initializers
mkdir -p db
```

## 7. Database Schema

```ruby
# spec/internal/db/schema.rb
ActiveRecord::Schema.define do
  create_table :active_admin_comments, force: true do |t|
    t.string :namespace
    t.text :body
    t.references :resource, polymorphic: true
    t.references :author, polymorphic: true
    t.timestamps
  end

  # Add your test models
  create_table :posts, force: true do |t|
    t.string :title
    t.text :body
    t.timestamps
  end
end
```

## 8. ActiveAdmin Configuration

```ruby
# spec/internal/config/initializers/active_admin.rb
ActiveAdmin.setup do |config|
  config.site_title = "Test App"
  config.authentication_method = false
  config.current_user_method = false
  config.batch_actions = true
end
```

## 9. Routes Configuration

```ruby
# spec/internal/config/routes.rb
Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  root to: 'admin/dashboard#index'
end
```

## 10. Install NPM Dependencies

```bash
cd spec/internal
npm init -y

# Install required packages
npm install --save-dev \
  @activeadmin/activeadmin@^3.3.0 \
  tailwindcss@^3.4.17 \
  esbuild@^0.24.2

# Install runtime dependencies (if your gem needs jQuery plugins)
npm install \
  jquery@^3.7.1 \
  your-vendor-package
```

## 11. Create Package.json Scripts

```json
{
  "name": "internal",
  "version": "1.0.0",
  "scripts": {
    "build:css": "node ./build_css.js",
    "build:js": "node esbuild.config.js",
    "build": "npm run build:js && npm run build:css",
    "watch": "npm run build:js --watch & npm run build:css -- --watch"
  },
  "dependencies": {
    "esbuild": "^0.24.2",
    "jquery": "^3.7.1"
  },
  "devDependencies": {
    "@activeadmin/activeadmin": "^3.3.0",
    "tailwindcss": "^3.4.17"
  }
}
```

## 12. Create Tailwind Config (WITH SAFELIST!)

```javascript
// spec/internal/tailwind.config.mjs
import activeAdminPlugin from '@activeadmin/activeadmin/plugin'
import { execSync } from 'node:child_process'

let activeAdminPath = null
try {
  activeAdminPath = execSync('bundle show activeadmin', { encoding: 'utf8' }).trim()
} catch (e) {
  // Continue without scanning if bundler unavailable
}

export default {
  content: [
    './app/admin/**/*.{arb,erb,html,rb}',
    './app/views/**/*.{arb,erb,html,rb}',
    './app/javascript/**/*.js',
    './app/js/**/*.js',
    ...(activeAdminPath ? [
      `${activeAdminPath}/vendor/javascript/flowbite.js`,
      `${activeAdminPath}/plugin.js`,
      `${activeAdminPath}/app/views/**/*.{arb,erb,html,rb}`,
    ] : [])
  ],
  darkMode: 'selector',
  plugins: [activeAdminPlugin],
  // CRITICAL: Without safelist, ActiveAdmin layout breaks!
  safelist: [
    // Grid and layout
    'grid', 'gap-4', 'gap-6', 'lg:grid-cols-3', 'md:grid-cols-2',
    'col-span-2', 'col-span-3', 'lg:col-span-2', 'lg:col-span-1',
    // Flexbox
    'flex', 'flex-col', 'flex-row', 'flex-wrap', 'items-center',
    'justify-between', 'justify-center', 'items-start', 'items-end',
    // Spacing
    'p-4', 'p-6', 'px-4', 'px-6', 'py-2', 'py-4', 'm-0', 'mx-auto',
    'mt-4', 'mb-4', 'ml-auto', 'mr-auto', 'space-y-4', 'space-x-4',
    // Display
    'block', 'inline-block', 'hidden', 'lg:hidden', 'lg:block', 'lg:flex',
    // Width/Height
    'w-full', 'w-auto', 'w-64', 'h-full', 'min-h-screen', 'max-w-7xl',
    // Typography
    'text-sm', 'text-base', 'text-lg', 'text-xl', 'font-medium', 'font-semibold',
    // Colors
    'bg-white', 'bg-gray-50', 'bg-gray-100', 'text-gray-900', 'text-gray-600',
    'dark:bg-gray-800', 'dark:bg-gray-900', 'dark:text-white', 'dark:text-gray-300',
    // Borders
    'border', 'border-gray-200', 'dark:border-gray-700', 'rounded-lg', 'rounded-md',
    // Forms
    'form-input', 'form-select', 'form-checkbox',
    // Position & Z-index
    'relative', 'absolute', 'fixed', 'sticky', 'top-0', 'left-0', 'right-0',
    'z-10', 'z-20', 'z-30', 'z-40', 'z-50',
    // Shadows
    'shadow', 'shadow-md', 'shadow-lg'
  ]
}
```

## 13. Create Build Script for CSS

```javascript
// spec/internal/build_css.js
#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const root = __dirname;
const inputPath = path.join(root, 'app/assets/stylesheets/active_admin_source.css');
const tmpPath = path.join(root, 'app/assets/stylesheets/__aa_tmp.css');
const outPath = path.join(root, 'app/assets/builds/active_admin.css');

function build() {
  // Read source file
  const src = fs.readFileSync(inputPath, 'utf8');
  
  // If you have vendor CSS to include:
  // const vendorCssPath = path.join(root, 'node_modules/your-package/dist/styles.css');
  // const vendorCss = fs.readFileSync(vendorCssPath, 'utf8');
  
  // Ensure Tailwind directives are first
  const tailwindDirectives = '@tailwind base;\n@tailwind components;\n@tailwind utilities;';
  
  // Build final CSS
  // With vendor: const tmpCss = `${tailwindDirectives}\n\n/* Vendor */\n${vendorCss}\n\n/* Custom */\n${src}`;
  const tmpCss = `${tailwindDirectives}\n\n${src}`;
  
  fs.writeFileSync(tmpPath, tmpCss, 'utf8');

  // Run Tailwind
  const res = spawnSync('npx', [
    'tailwindcss',
    '-c', 'tailwind.config.mjs',
    '-i', tmpPath,
    '-o', outPath
  ], { stdio: 'inherit', cwd: root });

  if (res.status !== 0) {
    process.exit(res.status);
  }

  fs.unlinkSync(tmpPath);
  console.log(`CSS built: ${outPath}`);
}

build();
```

## 14. Create jQuery Injection (if needed)

```javascript
// spec/internal/inject-jquery.js
// https://github.com/evanw/esbuild/issues/1681
export { default as $ } from 'jquery/dist/jquery.js'
export { default as jQuery } from 'jquery/dist/jquery.js'
```

## 15. Create JavaScript Entry Point

```javascript
// spec/internal/app/js/active_admin.js
import '@activeadmin/activeadmin';

// Import your gem's JavaScript module - users will use this exact import
// NOTE: In development, this needs to be resolved via esbuild alias to your local gem
import 'your_gem_name';
```

For development testing, create an esbuild config:

```javascript
// spec/internal/esbuild.config.js
const esbuild = require('esbuild');
const path = require('path');

const config = {
  entryPoints: ['app/js/active_admin.js'],
  bundle: true,
  sourcemap: true,
  format: 'esm',
  outdir: 'app/assets/builds',
  publicPath: '/assets',
  inject: ['./inject-jquery.js'],
  alias: {
    // Map your gem's module name to the actual file for development
    'your_gem_name': path.resolve(__dirname, '../../app/assets/javascripts/your_gem_main.js')
  }
};

// Build logic...
```

## 16. Create CSS Source

```css
/* spec/internal/app/assets/stylesheets/active_admin_source.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Your custom styles here */
```

## 17. Set Up Propshaft Assets

With Propshaft, assets in `app/assets/builds` are automatically served. No manifest configuration needed.

```css
/* spec/internal/app/assets/stylesheets/active_admin.css */
/* 
 * This file can be empty or include custom overrides
 * The real CSS is in builds/active_admin.css
 */
```

## 19. Create Test Models

```ruby
# spec/internal/app/models/post.rb
class Post < ActiveRecord::Base
  def self.ransackable_attributes(_auth_object = nil)
    %w[title body created_at updated_at]
  end
end
```

## 20. Create Admin Resources

```ruby
# spec/internal/app/admin/posts.rb
ActiveAdmin.register Post do
  permit_params :title, :body

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :title
      f.input :body, as: :text
      # Use your custom input types here
    end
    f.actions
  end
end
```

## 21. Build Assets

```bash
cd spec/internal
npm install
npm run build

# Verify output
ls -lah app/assets/builds/
# Should see active_admin.css (100KB+) and active_admin.js
```

## 22. Test the Setup

```bash
# From gem root
bundle exec rackup

# Visit http://localhost:9292/admin
# Should see styled ActiveAdmin interface
```

## 23. Set Up RSpec

```ruby
# spec/rails_helper.rb
ENV['RAILS_ENV'] ||= 'test'

require 'combustion'

Combustion.path = 'spec/internal'
Combustion.initialize! :active_record, :action_controller, :action_view do
  config.load_defaults Rails::VERSION::STRING.to_f
end

require 'rspec/rails'
require 'capybara/rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
```

## 24. Create Basic Spec

```ruby
# spec/features/admin_spec.rb
require 'rails_helper'

RSpec.describe 'Admin Interface', type: :feature do
  it 'loads the admin dashboard' do
    visit '/admin'
    expect(page).to have_content('Dashboard')
  end
  
  it 'has properly styled interface' do
    visit '/admin'
    # Check for Tailwind classes indicating proper styling
    expect(page).to have_css('.flex')
    expect(page).to have_css('.grid')
  end
end
```

## 25. Add to .gitignore

```
# .gitignore
spec/internal/node_modules/
spec/internal/app/assets/builds/
spec/internal/tmp/
spec/internal/log/
spec/internal/db/*.sqlite3
spec/internal/package-lock.json
```

## Checklist

- [ ] Gem structure created with proper dependencies
- [ ] Combustion test app generated
- [ ] config.ru with correct loading order
- [ ] NPM packages installed
- [ ] Tailwind configured with safelist
- [ ] CSS build script created
- [ ] JavaScript entry point set up
- [ ] jQuery injection (if needed)
- [ ] Asset manifests configured
- [ ] Test models and admin resources created
- [ ] Assets built successfully (>100KB CSS file)
- [ ] Server starts and admin interface is styled
- [ ] RSpec tests pass

## Common Issues

### Issue: "uninitialized constant ActiveAdmin"
**Solution**: Check config.ru loading order - ActiveAdmin must load AFTER Combustion.initialize!

### Issue: Unstyled admin pages
**Solution**: Ensure Tailwind safelist is included and CSS file is >100KB

### Issue: jQuery not defined
**Solution**: Add inject-jquery.js and use with esbuild --inject flag

### Issue: Vendor CSS not loading
**Solution**: Use build_css.js to concatenate vendor CSS before Tailwind processing

### Issue: Assets not loading / 404 errors
**Solution**: Ensure you're using Propshaft, not Sprockets. Check that assets are in `app/assets/builds/`

## Success Indicators

✅ Admin interface fully styled with proper layout  
✅ CSS file size > 100KB  
✅ No JavaScript console errors  
✅ Dark mode toggle works  
✅ Custom features/inputs working  
✅ Tests passing