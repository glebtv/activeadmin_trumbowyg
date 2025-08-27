# ActiveAdmin 4 Asset Pipeline – Critical JavaScript & Test Fixes (v3)

This document contains NEW findings and fixes discovered after v2, specifically for JavaScript functionality, dark mode, and test failures.

## CRITICAL: JavaScript Version Mismatch Issue

### Root Cause Discovery
The test app has **ActiveAdmin 3.3.0** in package.json but the Ruby gem is **ActiveAdmin 4.0.0-beta16**. This version mismatch completely breaks JavaScript functionality.

### Working Reference App
The fully working app at `/data/rslogin-ui/` has:
- ActiveAdmin 4.0.0-beta10 in both gem and npm package
- All JavaScript features working (dark mode, filters, batch actions)
- Properly configured esbuild with ESM modules

## Required Fixes

### 1. Fix NPM Dependencies (`/data/activeadmin_trumbowyg/spec/internal/package.json`)
```json
{
  "dependencies": {
    "@activeadmin/activeadmin": "^4.0.0-beta10",  // MUST match gem version
    "@rails/ujs": "^7.1.400",  // Required for Rails integration
    "esbuild": "^0.24.2",
    "jquery": "^3.7.1",
    "trumbowyg": "^2.28.0"
  },
  "devDependencies": {
    "tailwindcss": "^3.4.17"  // Move AA to dependencies, not devDeps!
  }
}
```

### 2. Fix JavaScript Imports (`/data/activeadmin_trumbowyg/spec/internal/app/js/active_admin.js`)
```javascript
// jQuery is injected globally via inject-jquery.js
import $ from 'jquery';
import 'trumbowyg';

// Import ActiveAdmin base (includes Rails UJS - DO NOT import Rails separately!)
import '@activeadmin/activeadmin';

// Import ALL ActiveAdmin features (REQUIRED for functionality)
import "@activeadmin/activeadmin/dist/active_admin/features/batch_actions";
import "@activeadmin/activeadmin/dist/active_admin/features/dark_mode_toggle";  // Critical for dark mode!
import "@activeadmin/activeadmin/dist/active_admin/features/has_many";
import "@activeadmin/activeadmin/dist/active_admin/features/filters";
import "@activeadmin/activeadmin/dist/active_admin/features/main_menu";
import "@activeadmin/activeadmin/dist/active_admin/features/per_page";

// Ensure jQuery is available globally
window.$ = window.jQuery = $;

// Initialize Trumbowyg editors
function initTrumbowygEditors() {
  $('[data-aa-trumbowyg]').each(function () {
    if (!$(this).hasClass('trumbowyg-textarea--active')) {
      let options = {
        svgPath: '/assets/trumbowyg/icons.svg'
      };
      options = $.extend({}, options, $(this).data('options'));
      $(this).trumbowyg(options);
      $(this).addClass('trumbowyg-textarea--active');
    }
  });
}

// Initialize on various events
$(document).ready(initTrumbowygEditors);
$(document).on('has_many_add:after', '.has_many_container', initTrumbowygEditors);
$(document).on('turbo:load turbolinks:load', initTrumbowygEditors);
```

### 3. Database Schema Fix (`/data/activeadmin_trumbowyg/spec/internal/db/schema.rb`)
Tests expect a `summary` field on Post model:
```ruby
create_table :posts, force: true do |t|
  t.string :title
  t.text :description
  t.text :summary  # ADD THIS FIELD
  t.text :body
  t.references :author
  t.timestamps
end
```

### 4. Update Admin Forms
#### `/data/activeadmin_trumbowyg/spec/internal/app/admin/posts.rb`
```ruby
permit_params :title, :description, :summary, :body, :author_id  # Add summary

form do |f|
  f.inputs do
    f.input :title
    f.input :author
    f.input :description, as: :text, input_html: { class: 'trumbowyg-input', 'data-aa-trumbowyg': true }
    f.input :summary, as: :text, input_html: { class: 'trumbowyg-input', 'data-aa-trumbowyg': true }  # ADD
    f.input :body, as: :text, input_html: { class: 'trumbowyg-input', 'data-aa-trumbowyg': true }
  end
  f.actions
end
```

#### `/data/activeadmin_trumbowyg/spec/internal/app/admin/authors.rb`
```ruby
ActiveAdmin.register Author do
  permit_params :name, :email, posts_attributes: [:id, :title, :description, :_destroy]
  
  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.has_many :posts, allow_destroy: true, new_record: true do |p|
        p.input :title
        p.input :description, as: :text, input_html: { class: 'trumbowyg-input', 'data-aa-trumbowyg': true }
      end
    end
    f.actions
  end
end
```

### 5. Model Updates
#### `/data/activeadmin_trumbowyg/spec/internal/app/models/author.rb`
```ruby
class Author < ApplicationRecord
  has_many :posts, dependent: :destroy
  accepts_nested_attributes_for :posts, allow_destroy: true  # ADD THIS
  # ... rest of model
end
```

#### `/data/activeadmin_trumbowyg/spec/internal/app/models/post.rb`
Update ransackable_attributes to include summary.

### 6. Test Data Fix (`/data/activeadmin_trumbowyg/spec/system/trumbowyg_editor_spec.rb`)
```ruby
let!(:post) do
  Post.create!(
    title: 'Test', 
    author: author, 
    description: '<p>Some content</p>', 
    summary: '<p>Post summary</p>',  # ADD THIS
    body: '<p>Post body</p>'
  )
end
```

### 7. Assets Initializer (`/data/activeadmin_trumbowyg/spec/internal/config/initializers/assets.rb`)
Create this file to ensure proper asset handling:
```ruby
Rails.application.config.assets.version = "1.0"
```

## CI/GitHub Actions Issues

### NPM Authentication Error
```
npm error code E401
npm error Unable to authenticate, your authentication token seems to be invalid.
```

**Research needed using:**
- https://github.com/actions/setup-node documentation
- Check if NPM_TOKEN secret is properly configured
- Verify .npmrc setup in the workflow

### GitHub CLI for Monitoring
Use `gh` command to view workflow runs and debug CI failures.

## Execution Order

1. **Update package.json** with correct ActiveAdmin version
2. **Run `npm install`** to get ActiveAdmin 4.0.0-beta10
3. **Fix JavaScript imports** to include all AA features
4. **Add summary field** to database schema
5. **Update admin forms** to include summary field
6. **Fix model associations** (accepts_nested_attributes_for)
7. **Rebuild assets**: `npm run build`
8. **Run tests**: `bundle exec rspec`

## Verification Commands
```bash
# Check JavaScript build
cd /data/activeadmin_trumbowyg/spec/internal
npm run build:js
# Should output ~344KB active_admin.js

# Check CSS build  
npm run build:css
# Should output ~110KB active_admin.css (with safelist)

# Start server
cd /data/activeadmin_trumbowyg
bundle exec rackup -p 9292

# Test dark mode
# Navigate to http://localhost:9292/admin and click dark mode toggle

# Run tests
bundle exec rspec spec/system/trumbowyg_editor_spec.rb
```

## Known Console Errors to Fix
- "If you load both jquery_ujs and rails-ujs, use rails-ujs only" - Fixed by not importing Rails separately
- jQuery not defined in tests - Ensure proper asset compilation in test environment

## Test Environment Issues
Tests fail with "jQuery is not defined" because assets aren't properly compiled/served in test environment. This needs investigation of how Combustion serves assets during tests.

## Trumbowyg Dark Mode
Reference: https://alex-d.github.io/Trumbowyg/demos/core/dark-theme.html
Need to integrate Trumbowyg's dark mode with ActiveAdmin's dark mode toggle.

## File Paths Summary
All paths are relative to `/data/activeadmin_trumbowyg/`:
- Main test app: `spec/internal/`
- JavaScript source: `spec/internal/app/js/active_admin.js`
- CSS build script: `spec/internal/build_css.js`
- Tailwind config: `spec/internal/tailwind.config.mjs`
- Package.json: `spec/internal/package.json`
- Built assets: `spec/internal/app/assets/builds/`
- Admin files: `spec/internal/app/admin/`
- Models: `spec/internal/app/models/`
- Database schema: `spec/internal/db/schema.rb`
- Test file: `spec/system/trumbowyg_editor_spec.rb`
- GitHub workflow: `.github/workflows/`