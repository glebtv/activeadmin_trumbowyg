# Setting Up Standalone ActiveAdmin 4 Application

This guide shows how to create a new standalone ActiveAdmin 4 application with proper asset pipeline configuration.

## Quick Start: ActiveAdmin Trumbowyg Installation

### For esbuild/webpack users (Modern Setup)
```bash
# Install via NPM
npm install @rocket-sensei/activeadmin_trumbowyg

# Import in your JavaScript
# app/javascript/application.js or app/javascript/active_admin.js
import '@rocket-sensei/activeadmin_trumbowyg'

# No generator needed! The package auto-initializes
```

### For Importmap/Propshaft users (Rails Default)
```bash
# Add gem to Gemfile
gem 'activeadmin_trumbowyg'

# Run generator
rails generate activeadmin_trumbowyg:install
```

## 1. Create Rails Application

```bash
# For Rails 8 (Propshaft included by default):
rails new my_admin_app --css=tailwind --javascript=esbuild
cd my_admin_app

# For Rails 7, we'll add Propshaft in the next step
```

## 2. Add ActiveAdmin to Gemfile

```ruby
# Gemfile
gem 'activeadmin', '~> 4.0.0.beta16'
gem 'importmap-rails', '~> 2.0'  # Required for ActiveAdmin 4

# For Rails 7, add Propshaft (Rails 8 includes it by default):
gem 'propshaft'  # Required - Sprockets is not supported

# Optional: Add your vendor packages
# gem 'activeadmin_trumbowyg'  # Or other AA extensions
```

```bash
bundle install
```

## 3. Install ActiveAdmin

```bash
rails generate active_admin:install

# This creates:
# - config/initializers/active_admin.rb
# - app/admin/ directory
# - db/migrate/xxx_create_active_admin_comments.rb
```

## 4. Run Migrations

```bash
rails db:create
rails db:migrate
rails db:seed  # Creates default admin user if using Devise
```

## 5. Install NPM Dependencies

```bash
# Install ActiveAdmin Tailwind plugin and other dependencies
npm install --save-dev @activeadmin/activeadmin@^3.3.0

# If you need jQuery plugins
npm install jquery

# Install vendor packages via NPM
# For activeadmin_trumbowyg gem users with esbuild/webpack:
npm install @rocket-sensei/activeadmin_trumbowyg

# Or install Trumbowyg directly:
# npm install trumbowyg
```

## 6. Configure Tailwind (CRITICAL!)

```javascript
// tailwind.config.js - Convert to ESM format
// Rename to tailwind.config.mjs

import activeAdminPlugin from '@activeadmin/activeadmin/plugin'
import { execSync } from 'node:child_process'

let activeAdminPath = null
try {
  activeAdminPath = execSync('bundle show activeadmin', { encoding: 'utf8' }).trim()
} catch (e) {
  console.warn('Could not find activeadmin gem path')
}

export default {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
    './app/admin/**/*.rb',
    // Include ActiveAdmin gem views
    ...(activeAdminPath ? [
      `${activeAdminPath}/app/views/**/*.{arb,erb,html,rb}`,
      `${activeAdminPath}/vendor/javascript/flowbite.js`,
      `${activeAdminPath}/plugin.js`,
    ] : [])
  ],
  darkMode: 'selector',
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', 'sans-serif'],
      },
    },
  },
  plugins: [
    activeAdminPlugin,
    // Other plugins like forms, typography
  ],
  // CRITICAL: Add safelist for ActiveAdmin dynamic classes
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
    'shadow', 'shadow-md', 'shadow-lg',
    // Tables
    'table-auto', 'border-collapse',
    // Buttons
    'inline-flex', 'cursor-pointer'
  ]
}
```

## 7. Update Package.json Scripts

```json
{
  "name": "my-admin-app",
  "scripts": {
    "build:css": "tailwindcss -c tailwind.config.mjs -i ./app/assets/stylesheets/application.tailwind.css -o ./app/assets/builds/application.css --minify",
    "build:js": "esbuild app/javascript/*.* --bundle --sourcemap --format=esm --outdir=app/assets/builds --public-path=/assets --inject:./inject-jquery.js",
    "build": "npm run build:css && npm run build:js",
    "watch:css": "npm run build:css -- --watch",
    "watch:js": "npm run build:js -- --watch"
  }
}
```

## 8. Create jQuery Injection (if using jQuery plugins)

```javascript
// inject-jquery.js (in project root)
export { default as $ } from 'jquery/dist/jquery.js'
export { default as jQuery } from 'jquery/dist/jquery.js'
```

## 9. Set Up Application CSS

```css
/* app/assets/stylesheets/application.tailwind.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

/* ActiveAdmin custom styles */
@layer components {
  /* Custom component styles */
  .admin-button {
    @apply px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700;
  }
}

/* Import vendor CSS if needed */
/* Note: @rocket-sensei/activeadmin_trumbowyg NPM package includes CSS automatically */
/* For manual Trumbowyg setup: @import 'trumbowyg/dist/ui/trumbowyg.css'; */
```

## 10. Set Up Application JavaScript

```javascript
// app/javascript/application.js
import "@hotwired/turbo-rails"
import "./controllers"

// If using jQuery and plugins
import $ from 'jquery'
window.$ = window.jQuery = $

// Import vendor libraries via NPM packages
// For activeadmin_trumbowyg gem users with esbuild/webpack:
// import '@rocket-sensei/activeadmin_trumbowyg'

// Or import Trumbowyg directly:
// import 'trumbowyg'

// Note: No generator needed when using esbuild/webpack with NPM packages
// The NPM package automatically handles initialization

// For manual plugin initialization if needed:
document.addEventListener('DOMContentLoaded', () => {
  initializePlugins()
})

document.addEventListener('turbo:load', () => {
  initializePlugins()
})

function initializePlugins() {
  // Initialize your jQuery plugins if not auto-initialized
  // $('.select2').select2()
  // $('[data-trumbowyg]').trumbowyg() // Only if not using NPM package auto-init
}
```

## 11. Configure ActiveAdmin

```ruby
# config/initializers/active_admin.rb
ActiveAdmin.setup do |config|
  config.site_title = "My Admin App"
  
  # Authentication (if using Devise)
  config.authentication_method = :authenticate_admin_user!
  config.current_user_method = :current_admin_user
  config.logout_link_path = :destroy_admin_user_session_path
  
  # Or disable authentication for development
  # config.authentication_method = false
  # config.current_user_method = false
  
  config.batch_actions = true
  config.filter_attributes = [:encrypted_password, :password, :password_confirmation]
  config.localize_format = :long
end
```

## 12. Create Sample Model and Admin Resource

```bash
# Generate a model
rails generate model Product name:string description:text price:decimal active:boolean
rails db:migrate
```

```ruby
# app/admin/products.rb
ActiveAdmin.register Product do
  permit_params :name, :description, :price, :active

  index do
    selectable_column
    id_column
    column :name
    column :price do |product|
      number_to_currency product.price
    end
    column :active
    column :created_at
    actions
  end

  filter :name
  filter :price
  filter :active
  filter :created_at

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :description
      f.input :price
      f.input :active
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :description
      row :price do |product|
        number_to_currency product.price
      end
      row :active
      row :created_at
      row :updated_at
    end
  end
end
```

## 13. Build Assets

```bash
npm run build
```

## 14. Start Rails Server

```bash
rails server
```

Visit http://localhost:3000/admin

Default credentials (if using Devise):
- Email: admin@example.com
- Password: password

## 15. Production Deployment

### Asset Precompilation

```ruby
# config/environments/production.rb
config.assets.compile = false
config.assets.precompile += %w[ application.js application.css ]
```

### Build Command for Production

```bash
RAILS_ENV=production bundle exec rails assets:precompile
```

### Heroku Deployment

```json
// package.json
{
  "scripts": {
    "build": "npm run build:css && npm run build:js",
    "build:css": "tailwindcss -c tailwind.config.mjs -i ./app/assets/stylesheets/application.tailwind.css -o ./app/assets/builds/application.css --minify",
    "build:js": "esbuild app/javascript/*.* --bundle --sourcemap --format=esm --outdir=app/assets/builds --public-path=/assets --minify"
  }
}
```

Add buildpacks:
```bash
heroku buildpacks:add heroku/nodejs
heroku buildpacks:add heroku/ruby
```

## 16. Adding Vendor Packages (Example: Trumbowyg)

### Method 1: Using the NPM Package (Recommended for esbuild/webpack)

```bash
# Install the official NPM package
npm install @rocket-sensei/activeadmin_trumbowyg
```

```javascript
// app/javascript/application.js or app/javascript/active_admin.js
import '@rocket-sensei/activeadmin_trumbowyg'

// That's it! The package auto-initializes Trumbowyg on elements with data-provider="trumbowyg"
// No generator needed for esbuild/webpack setups
```

```ruby
# app/admin/posts.rb
ActiveAdmin.register Post do
  form do |f|
    f.inputs do
      f.input :title
      f.input :body, as: :text, input_html: { 
        'data-provider': 'trumbowyg',
        class: 'trumbowyg-editor' 
      }
    end
    f.actions
  end
end
```

### Method 2: Using Trumbowyg Directly (Manual Setup)

```bash
npm install trumbowyg jquery
```

```javascript
// app/javascript/admin.js
import $ from 'jquery'
import 'trumbowyg'

window.$ = window.jQuery = $

function initTrumbowyg() {
  $('[data-trumbowyg]').each(function() {
    if (!$(this).hasClass('trumbowyg-active')) {
      $(this).trumbowyg({
        svgPath: '/assets/trumbowyg/icons.svg'
      })
      $(this).addClass('trumbowyg-active')
    }
  })
}

document.addEventListener('DOMContentLoaded', initTrumbowyg)
document.addEventListener('turbo:load', initTrumbowyg)
```

Copy icons (only needed for manual setup):
```bash
cp node_modules/trumbowyg/dist/ui/icons.svg public/assets/trumbowyg/
```

## Common Issues & Solutions

### Issue: Unstyled Admin Interface
**Solution**: 
1. Ensure Tailwind safelist is configured
2. Check that CSS file is > 100KB
3. Rebuild assets with `npm run build`

### Issue: JavaScript Not Loading
**Solution**:
1. Check esbuild configuration
2. Ensure importmap or esbuild is properly configured
3. Check browser console for errors

### Issue: Dark Mode Not Working
**Solution**:
1. Ensure `darkMode: 'selector'` in Tailwind config
2. ActiveAdmin plugin handles dark mode toggle

### Issue: Forms Not Styled
**Solution**:
1. Add form-related classes to safelist
2. Ensure ActiveAdmin plugin is loaded

## Testing Setup

```ruby
# Gemfile - test group
group :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'factory_bot_rails'
end
```

```ruby
# spec/features/admin_spec.rb
require 'rails_helper'

RSpec.describe 'Admin Interface', type: :feature do
  it 'loads the dashboard' do
    visit '/admin'
    expect(page).to have_content('Dashboard')
  end
end
```

## Folder Structure Summary

```
my_admin_app/
├── app/
│   ├── admin/           # ActiveAdmin resources
│   ├── assets/
│   │   ├── builds/      # Compiled assets
│   │   ├── config/
│   │   │   └── manifest.js
│   │   └── stylesheets/
│   │       └── application.tailwind.css
│   └── javascript/
│       ├── application.js
│       └── active_admin.js  # Optional: ActiveAdmin-specific JS
├── config/
│   └── initializers/
│       └── active_admin.rb
├── node_modules/
│   └── @rocket-sensei/
│       └── activeadmin_trumbowyg/  # NPM package location
├── public/
│   └── assets/          # Static vendor assets
├── package.json
├── tailwind.config.mjs  # ESM format!
└── inject-jquery.js     # If using jQuery
```

## Key Installation Differences

### NPM Package (@rocket-sensei/activeadmin_trumbowyg)
- **For**: esbuild/webpack users
- **Installation**: `npm install @rocket-sensei/activeadmin_trumbowyg`
- **Import**: `import '@rocket-sensei/activeadmin_trumbowyg'`
- **Generator**: Not needed
- **JavaScript paths**: Uses `active_admin/` prefix
- **Auto-initialization**: Yes, handles Turbo events automatically

### Ruby Gem (activeadmin_trumbowyg)
- **For**: Importmap/Propshaft users
- **Installation**: Add to Gemfile
- **Generator**: Required (`rails g activeadmin_trumbowyg:install`)
- **JavaScript paths**: Uses `active_admin/` prefix
- **Asset handling**: Via Rails asset pipeline

## Success Checklist

✅ Rails app created with esbuild and Tailwind  
✅ ActiveAdmin installed and configured  
✅ Tailwind config with ActiveAdmin plugin and safelist  
✅ Assets building correctly (CSS > 100KB)  
✅ Admin interface fully styled  
✅ Dark mode toggle working  
✅ Forms properly styled  
✅ No JavaScript console errors  
✅ Vendor packages integrated (if using NPM: @rocket-sensei/activeadmin_trumbowyg)  
✅ Trumbowyg editor rendering on forms with `data-provider="trumbowyg"`