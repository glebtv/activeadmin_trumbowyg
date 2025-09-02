# ActiveAdmin Trumbowyg 4.0 - Installation and Upgrade Guide

This guide helps you install or upgrade to version 4.0 which supports ActiveAdmin 4 only.

## Prerequisites

Before installing, ensure you have:
- Ruby >= 3.2
- Rails >= 7.0 (with Propshaft) or Rails 8+
- ActiveAdmin ~> 4.0.0.beta
- Modern JavaScript bundler (esbuild, webpack, or Vite)
- **Note:** Sprockets is NOT supported. ActiveAdmin 4 requires Propshaft.

## Step 1: Install the Gem

Add to your Gemfile:

```ruby
# Ruby gem
gem 'rs-activeadmin_trumbowyg', '~> 4.0'

# For Rails 7, also add Propshaft (Rails 8 includes it by default):
gem 'propshaft' # Required for Rails 7
```

Run `bundle update activeadmin_trumbowyg`

## Step 2: Install the NPM Package

```bash
npm install @rocket-sensei/activeadmin_trumbowyg@^4.0.0
# or
yarn add @rocket-sensei/activeadmin_trumbowyg@^4.0.0
```

**Note:** If upgrading from an older version, remove any old Sprockets directives:
- Remove `//= require` directives from JavaScript files
- Remove `@import` directives for trumbowyg from SCSS files

## Step 3: Install and Configure Based on Your Bundler

Based on your JavaScript bundler:

### For esbuild (recommended)

```bash
# Install the NPM package
npm install @rocket-sensei/activeadmin_trumbowyg
```

Then add to your `app/javascript/active_admin.js`:
```javascript
// ActiveAdmin Trumbowyg Editor
import '@rocket-sensei/activeadmin_trumbowyg';
```

Add Trumbowyg styles to your stylesheet (`app/assets/stylesheets/active_admin.scss`):
```scss
@import url('https://cdn.jsdelivr.net/npm/trumbowyg@2/dist/ui/trumbowyg.min.css');
```

**Note:** No generator needed for esbuild/webpack - just install the NPM package and import it!

### For webpack

```bash
# Install the NPM package
npm install @rocket-sensei/activeadmin_trumbowyg
```

Then add to your `app/javascript/packs/active_admin.js`:
```javascript
// ActiveAdmin Trumbowyg Editor
import '@rocket-sensei/activeadmin_trumbowyg';
```

Add Trumbowyg styles to your stylesheet:
```scss
@import url('https://cdn.jsdelivr.net/npm/trumbowyg@2/dist/ui/trumbowyg.min.css');
```

### For importmap

```bash
rails generate active_admin:trumbowyg:install --bundler=importmap
```

This will:
1. Add pins to `config/importmap.rb`:
```ruby
pin "jquery", to: "https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"
pin "trumbowyg", to: "https://cdn.jsdelivr.net/npm/trumbowyg@2/dist/trumbowyg.min.js"
pin "active_admin_trumbowyg", to: "active_admin_trumbowyg.js"
```
2. Add import to your JavaScript

**Note:** The generator is still needed for importmap to properly configure the pins.

## Step 4: Build Your Assets

For esbuild:
```bash
npm run build
```

For webpack:
```bash
bin/webpack
```

For importmap:
```bash
# Just restart your Rails server
rails server
```

## Step 5: Production Setup

No additional setup needed - all assets are handled automatically through the NPM package or CDN.

## What's Changed?

### Architecture Changes

**Version 1.x (Old):**
- Used Rails Asset Pipeline with Sprockets
- Required manual asset includes
- JavaScript paths used `activeadmin/` prefix
- Assets copied to each app

**Version 2.0 (New):**
- Distributed via NPM as `@rocket-sensei/activeadmin_trumbowyg`
- Uses modern JavaScript modules (ESM)
- Single import loads everything (includes jQuery and Trumbowyg)
- JavaScript paths use `active_admin/` prefix (Rails convention)
- Automatic dark mode support
- Better ActiveAdmin 4 integration
- No generator needed for esbuild/webpack users

### JavaScript Changes

The gem now provides a complete initialization module via NPM. You no longer need to write initialization code - just import the module:

```javascript
// Old way (1.x) - manual initialization
$('.trumbowyg-input').trumbowyg({
  // options
});

// New way (2.0) - automatic initialization via NPM package
import '@rocket-sensei/activeadmin_trumbowyg';  // That's it!
```

For esbuild/webpack users, the package is now distributed via NPM as `@rocket-sensei/activeadmin_trumbowyg`, making installation and updates much simpler.

### Form Usage (Unchanged)

The form usage remains the same:

```ruby
form do |f|
  f.inputs 'Article' do
    f.input :title
    f.input :description, as: :trumbowyg
  end
  f.actions
end
```

## Troubleshooting

### Issue: "Trumbowyg library is required but not found"

**Solution:** For esbuild/webpack users, the NPM package handles dependencies automatically. Just ensure you have the package installed:

```bash
npm install @rocket-sensei/activeadmin_trumbowyg
```

Then import it:
```javascript
import '@rocket-sensei/activeadmin_trumbowyg';
```

For importmap users, ensure jQuery and Trumbowyg are pinned before the ActiveAdmin Trumbowyg module.

### Issue: Styles not loading

**Solution:** Check that the CDN link was added to your stylesheet:
```scss
@import url('https://cdn.jsdelivr.net/npm/trumbowyg@2/dist/ui/trumbowyg.min.css');
```

### Issue: Dark mode not working

Dark mode support is automatic in version 2.0. If it's not working:
1. Ensure you're using the latest ActiveAdmin 4.x
2. Check that the gem's JavaScript is properly loaded
3. Verify dark mode toggle works for other ActiveAdmin elements

### Issue: Custom plugins not working

For esbuild/webpack users with custom Trumbowyg plugins:

```javascript
// Import the main package first
import '@rocket-sensei/activeadmin_trumbowyg';

// Then import any additional Trumbowyg plugins
import 'trumbowyg/dist/plugins/upload/trumbowyg.upload.js';

// Configure custom options via data attributes in your form
```

Note: The NPM package includes jQuery and base Trumbowyg automatically.

## Manual Cleanup (Optional)

After successful upgrade, you can remove:
- Any custom Trumbowyg initialization code
- Old vendor JavaScript files
- Unused Trumbowyg-related assets

## Need Help?

- [Report issues](https://github.com/glebtv/activeadmin_trumbowyg/issues)
- [View README](https://github.com/glebtv/activeadmin_trumbowyg#readme)
- [See examples](https://github.com/glebtv/activeadmin_trumbowyg/tree/main/examples)

## Quick Reference

### Installation Commands

```bash
# For esbuild/webpack - NPM package (no generator needed)
npm install @rocket-sensei/activeadmin_trumbowyg

# For importmap - Use generator
rails generate active_admin:trumbowyg:install --bundler=importmap
```

### Required Imports (esbuild/webpack)

```javascript
// Single import - includes all dependencies
import '@rocket-sensei/activeadmin_trumbowyg';
```

### Required Styles

```scss
// Add to your active_admin.scss
@import url('https://cdn.jsdelivr.net/npm/trumbowyg@2/dist/ui/trumbowyg.min.css');
```

### Form Input

```ruby
f.input :content, as: :trumbowyg
```

### With Options

```ruby
f.input :content, as: :trumbowyg, input_html: { 
  data: { 
    options: { 
      btns: [['bold', 'italic'], ['link']]
    } 
  } 
}
```