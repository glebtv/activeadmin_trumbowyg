# Upgrading from ActiveAdmin Trumbowyg 1.x to 2.0

This guide helps you upgrade from version 1.x (ActiveAdmin 3) to version 2.0 (ActiveAdmin 4).

## Prerequisites

Before upgrading, ensure you have:
- Ruby >= 3.2
- Rails >= 7.0
- ActiveAdmin ~> 4.0.0.beta
- Propshaft (Rails 7) or Rails 8 (includes Propshaft by default)
- **Note:** Sprockets is not supported. This gem requires Propshaft for asset management.

## Step 1: Update the Gem

Update your Gemfile:

```ruby
# Old
gem 'activeadmin_trumbowyg', '~> 1.0'

# New
gem 'activeadmin_trumbowyg', '~> 2.0'

# For Rails 7, also add Propshaft (Rails 8 includes it by default):
gem 'propshaft' # Required for Rails 7
```

Run `bundle update activeadmin_trumbowyg`

## Step 2: Remove Old Asset Pipeline Code

**Remove from `app/assets/javascripts/active_admin.js`:**
```javascript
//= require activeadmin/trumbowyg/trumbowyg
//= require activeadmin/trumbowyg_input
```

**Remove from `app/assets/stylesheets/active_admin.scss`:**
```scss
@import 'activeadmin/trumbowyg/trumbowyg';
@import 'activeadmin/trumbowyg_input';
```

## Step 3: Run the Installation Generator

Based on your JavaScript bundler:

### For esbuild (recommended)

```bash
rails generate active_admin:trumbowyg:install --bundler=esbuild
```

This will:
1. Install npm packages: `jquery`, `trumbowyg`, `activeadmin_trumbowyg`
2. Add imports to your `app/javascript/active_admin.js`:
```javascript
// ActiveAdmin Trumbowyg Editor
import $ from 'jquery';
import 'trumbowyg';

// Ensure jQuery is globally available
window.$ = window.jQuery = $;

// Initialize Trumbowyg for ActiveAdmin
import 'activeadmin_trumbowyg';
```
3. Add Trumbowyg styles via CDN to your stylesheet

### For importmap

```bash
rails generate active_admin:trumbowyg:install --bundler=importmap
```

This will:
1. Add pins to `config/importmap.rb`:
```ruby
pin "jquery", to: "https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"
pin "trumbowyg", to: "https://cdn.jsdelivr.net/npm/trumbowyg@2/dist/trumbowyg.min.js"
pin "activeadmin_trumbowyg", to: "activeadmin_trumbowyg.js"
```
2. Add import to your JavaScript

### For webpack

```bash
rails generate active_admin:trumbowyg:install --bundler=webpack
```

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

For production environments with asset precompilation:

```bash
rails trumbowyg:nondigest
```

This ensures icon assets are available in production.

## What's Changed?

### Architecture Changes

**Version 1.x (Old):**
- Used Rails Asset Pipeline
- Required manual asset includes
- Code was copied to each app

**Version 2.0 (New):**
- Uses modern JavaScript modules (ESM)
- Single import loads everything
- Code lives in the gem, not your app
- Automatic dark mode support
- Better ActiveAdmin 4 integration

### JavaScript Changes

The gem now provides a complete initialization module. You no longer need to write initialization code - just import the module:

```javascript
// Old way (1.x) - manual initialization
$('.trumbowyg-input').trumbowyg({
  // options
});

// New way (2.0) - automatic initialization
import 'activeadmin_trumbowyg';  // That's it!
```

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

**Solution:** Ensure jQuery and Trumbowyg are imported BEFORE activeadmin_trumbowyg:

```javascript
import $ from 'jquery';
import 'trumbowyg';
window.$ = window.jQuery = $;
import 'activeadmin_trumbowyg';  // Must be last
```

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

Add plugin imports after the main imports:

```javascript
import $ from 'jquery';
import 'trumbowyg';
import 'trumbowyg/dist/plugins/upload/trumbowyg.upload.js';  // Add plugins here

window.$ = window.jQuery = $;
import 'activeadmin_trumbowyg';
```

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

### Generator Options

```bash
# For esbuild (recommended)
rails generate active_admin:trumbowyg:install --bundler=esbuild

# For importmap
rails generate active_admin:trumbowyg:install --bundler=importmap

# For webpack
rails generate active_admin:trumbowyg:install --bundler=webpack
```

### Required Imports (esbuild/webpack)

```javascript
import $ from 'jquery';
import 'trumbowyg';
window.$ = window.jQuery = $;
import 'activeadmin_trumbowyg';
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