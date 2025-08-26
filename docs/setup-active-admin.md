# Setting up ActiveAdmin 4 with Searchable Select

This guide documents how to set up a working ActiveAdmin 4 application with proper Tailwind CSS styling and the searchable_select gem using esbuild for JavaScript bundling.

## The Production Build Problem

The main issue with ActiveAdmin 4 in production is that Select2 doesn't properly attach to jQuery when using modern JavaScript bundlers. This results in the error:
```
select2 is not a function
```

This happens because:
1. Modern bundlers don't automatically attach jQuery plugins to the global jQuery object
2. Minification in production can break plugin initialization
3. The load order of scripts may differ between development and production

## Solution Overview

The gem now provides multiple integration paths:

1. **ES Module** (`src/searchable_select.js`) - For esbuild/webpack with explicit Select2 initialization
2. **Importmap Version** (`vendor/assets/javascripts/activeadmin-searchable_select.js`) - For Rails importmap without build step
3. **Installation Generator** - Automated setup for different bundlers

## Key Requirements

1. **ActiveAdmin 4.x** (currently in beta)
2. **Rails 7.x or 8.x** with importmap-rails or esbuild
3. **Tailwind CSS v3** (NOT v4) - ActiveAdmin's plugin is not compatible with Tailwind v4
4. **Node.js and npm** for managing JavaScript dependencies
5. **esbuild** or **importmap** for JavaScript bundling

## Step-by-Step Setup

### 1. Create a new Rails application

```bash
rails new demo-app
cd demo-app
```

### 2. Add required gems to Gemfile

```ruby
# Admin interface
gem "activeadmin", "4.0.0.beta15"  # or latest beta
gem "devise"
gem "importmap-rails"
gem "sassc-rails"  # Required for ActiveAdmin

# For development
gem "sqlite3", "~> 2.1"  # Rails 8 compatibility

# Add the searchable_select gem
gem "activeadmin-searchable_select", path: ".."  # or from rubygems
```

### 3. Install gems and ActiveAdmin

```bash
bundle install
rails generate devise:install
rails generate devise User
rails generate active_admin:install
rails db:create db:migrate db:seed
```

### 4. Set up JavaScript with esbuild

Create `package.json`:
```json
{
  "name": "demo-app",
  "private": true,
  "dependencies": {
    "@activeadmin/activeadmin": "^4.0.0-beta15",
    "@codevise/activeadmin-searchable_select": "^1.8.0",
    "esbuild": "^0.24.2",
    "flowbite": "^2.5.2",
    "jquery": "^3.7.1",
    "select2": "^4.1.0-rc.0",
    "@rails/ujs": "^7.1.3",
    "tailwindcss": "^3.4.0"
  },
  "scripts": {
    "build": "esbuild app/js/*.* --bundle --sourcemap --format=esm --outdir=app/assets/builds --inject:./inject-jquery.js --public-path=/assets",
    "watch": "npm run build -- --watch",
    "start": "npm run watch",
    "build:css": "tailwindcss -i ./app/assets/stylesheets/active_admin.css -o ./app/assets/builds/active_admin.css --minify -c tailwind-active_admin.config.js"
  }
}
```

Install npm dependencies:
```bash
npm install
```

### 5. Create jQuery injection file for esbuild

Create `inject-jquery.js`:
```javascript
export { default as $ } from 'jquery/dist/jquery.js'
export { default as jQuery } from 'jquery/dist/jquery.js'
```

### 6. Set up JavaScript modules

Create `app/js/active_admin.js`:
```javascript
import "@activeadmin/activeadmin";

// Fix for production builds: Explicitly initialize Select2 on jQuery
import $ from 'jquery';
import select2 from 'select2';

// Critical: This line fixes the "select2 is not a function" error in production
select2($);

// Ensure jQuery is globally available for ActiveAdmin
window.$ = window.jQuery = $;

// Now import searchable select functionality
import '@codevise/activeadmin-searchable_select';
```

**Note:** The explicit `select2($)` call is critical for production builds. Without it, Select2 won't attach to jQuery properly when the code is minified.

### 7. Configure importmap and asset pipeline

Update `config/importmap.rb`:
```ruby
pin "application"
pin "active_admin", to: "active_admin.js", preload: true
```

Update `app/assets/config/manifest.js`:
```javascript
//= link_tree ../builds
```

### 8. Set up Tailwind CSS v3

Create or update `app/assets/stylesheets/active_admin.css`:
```css
@import "active_admin/searchable_select_tailwind.css";
@import url('https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css');

/* Tailwind directives */
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Your custom ActiveAdmin styles */
```

Build CSS with npm:
```bash
npm run build:css
```

### 9. Build JavaScript with esbuild

```bash
npm run build
```

For development with watch mode:
```bash
npm run start
```

### 10. Set up models with proper Ransack configuration

```ruby
class User < ApplicationRecord
  has_many :posts
  
  # Display method for searchable select
  def display_name
    "#{name} (#{email})"
  end
  
  # Ransack 4.x compatibility
  def self.ransackable_attributes(auth_object = nil)
    ["name", "email", "department", "created_at", "updated_at"]
  end
  
  def self.ransackable_associations(auth_object = nil)
    ["posts"]
  end
end
```

### 11. Configure ActiveAdmin resources

```ruby
ActiveAdmin.register User do
  permit_params :name, :email, :department
  
  # IMPORTANT: Use actual database column for text_attribute
  # Use display_text lambda for custom display format
  searchable_select_options(
    scope: User,
    text_attribute: :name,  # Must be a real database column for filtering
    display_text: ->(record) { record.display_name }  # Custom display format
  )
  
  index do
    selectable_column
    id_column
    column :name
    column :email
    column :department
    actions
  end
  
  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.input :department
    end
    f.actions
  end
end

ActiveAdmin.register Post do
  permit_params :title, :content, :user_id
  
  form do |f|
    f.inputs do
      f.input :title
      f.input :content
      f.input :user, as: :searchable_select, ajax: true
    end
    f.actions
  end
end
```

## Common Issues and Solutions

### Production Build Issues

#### "select2 is not a function" Error

**Problem**: Select2 doesn't work in production but works in development.

**Cause**: Modern bundlers (esbuild, webpack) don't automatically attach jQuery plugins to the jQuery object. The minification process in production can break the plugin initialization.

**Solution**: Explicitly initialize Select2 on jQuery after importing both:

```javascript
import $ from 'jquery';
import select2 from 'select2';

// This line is REQUIRED for production builds
select2($);

// Also ensure jQuery is globally available
window.$ = window.jQuery = $;
```

#### Using the Installation Generator

For automated setup, use the provided generator:

```bash
# For esbuild (recommended for ActiveAdmin 4)
rails generate active_admin:searchable_select:install

# For importmap (no build step required)
rails generate active_admin:searchable_select:install --bundler=importmap

# For webpack
rails generate active_admin:searchable_select:install --bundler=webpack
```

### Rails 8 Compatibility

1. **fixture_path= error in tests**: Add this to `spec/rails_helper.rb`:
   ```ruby
   module FixturePathPatch
     def fixture_path=(path)
       # No-op for Rails 8 compatibility
     end
     
     def fixture_path
       nil
     end
   end
   
   RSpec.configure do |config|
     config.include FixturePathPatch
   end
   ```

2. **show_exceptions changes**: Update test specs:
   ```ruby
   around do |example|
     if Rails.version >= "8.0"
       Rails.application.config.action_dispatch.show_exceptions = :none
     else
       Rails.application.config.action_dispatch.show_exceptions = false
     end
     example.run
     # Reset after test
   end
   ```

### JavaScript Module Errors

1. **"Failed to resolve module specifier 'jquery'"**: This happens with importmap. Solution: Use esbuild with inject-jquery.js pattern.

2. **Rails UJS conflict**: "If you load both jquery_ujs and rails-ujs, use rails-ujs only"
   - Solution: Comment out `Rails.start()` in active_admin.js as ActiveAdmin already initializes it

### Search Not Filtering

**Problem**: The search returns all records instead of filtering.

**Solution**: Ensure `text_attribute` is set to an actual database column, not a method:
```ruby
# Wrong - display_name is a method, not a column
searchable_select_options(scope: User, text_attribute: :display_name)

# Correct - use database column for filtering, method for display
searchable_select_options(
  scope: User,
  text_attribute: :name,  # Real column for Ransack to filter
  display_text: ->(record) { record.display_name }  # Method for display
)
```

### Dark Mode Styling

The gem includes comprehensive Tailwind CSS styles for dark mode support. If Select2 dropdowns don't style correctly in dark mode, ensure the searchable_select_tailwind.css is imported.

## Verification

1. Start the Rails server: `rails server`
2. Visit: `http://localhost:3000/admin`
3. Login with: `admin@example.com` / `password`
4. Check that:
   - Dark theme toggle works ✓
   - Tailwind styling is applied ✓
   - Select2 dropdowns are initialized on searchable_select fields ✓
   - Search filtering works correctly ✓

## Development Workflow

### Running in development

```bash
# Terminal 1: Rails server
rails server

# Terminal 2: JavaScript watch
npm run start

# Terminal 3: CSS watch (if needed)
npm run build:css -- --watch
```

### Building for production

```bash
npm run build
npm run build:css
rails assets:precompile
```

## Key Differences from Previous Approaches

1. **esbuild instead of importmap**: Importmap had issues resolving jQuery and Select2 modules
2. **inject-jquery.js pattern**: Ensures jQuery is available globally for Select2
3. **Separate app/js directory**: Keeps modern JavaScript separate from legacy Sprockets assets
4. **No jquery-rails gem**: Using npm packages instead
5. **Proper text_attribute configuration**: Must use database columns for filtering

## Troubleshooting

### Select2 styles not loading

**Cause**: CSS not imported
**Solution**: Add Select2 CSS via CDN or npm package

### Selects not initializing on dynamic content

**Cause**: Event listeners not properly set up
**Solution**: The updated code now listens for both Turbo and Turbolinks events

### jQuery undefined errors

**Cause**: jQuery not globally available
**Solution**: Ensure `window.$ = window.jQuery = $` is set

## Current Status

✅ Rails 7 and 8 compatibility
✅ ActiveAdmin 4.0.0.beta support
✅ Tailwind CSS v3 with dark mode
✅ Select2 initialization fixed for production builds
✅ Search filtering with Ransack
✅ Ajax-powered searchable selects
✅ Installation generator for easy setup
✅ Support for esbuild, importmap, and webpack

This setup provides a fully functional ActiveAdmin 4 application with searchable select functionality that works correctly in both development and production environments.