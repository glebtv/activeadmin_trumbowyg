# ActiveAdmin 4 Trumbowyg Setup - Final Working Solution

## Overview
ActiveAdmin 4 uses importmap-rails and doesn't support `register_javascript` anymore. The solution is to build JavaScript with esbuild and load it through Sprockets.

## Complete Setup Steps

### 1. Directory Structure
```
spec/internal/
├── app/
│   ├── assets/
│   │   ├── builds/         # Esbuild output
│   │   ├── javascripts/    # Sprockets assets
│   │   │   ├── active_admin.js
│   │   │   ├── trumbowyg_bundle.js
│   │   │   └── trumbowyg_loader.js
│   │   └── stylesheets/
│   │       ├── active_admin.css
│   │       ├── active_admin_compiled.css
│   │       ├── active_admin_source.css
│   │       └── trumbowyg.min.css
│   ├── js/                 # Source JavaScript
│   │   └── active_admin.js
│   └── admin/
│       └── posts.rb
├── public/
│   └── assets/
│       └── trumbowyg/
│           └── icons.svg
├── config/
│   └── importmap.rb
├── package.json
└── tailwind.config.mjs
```

### 2. Install Dependencies

```bash
cd spec/internal
npm init -y
npm install jquery trumbowyg esbuild tailwindcss @activeadmin/activeadmin
```

### 3. Create jQuery Injection File

**CRITICAL**: This file is essential for proper jQuery handling with esbuild. Create `inject-jquery.js`:

```javascript
// https://github.com/evanw/esbuild/issues/1681
// This file injects jQuery as a global for all modules
export { default as $ } from 'jquery/dist/jquery.js'
export { default as jQuery } from 'jquery/dist/jquery.js'
```

### 4. Package.json Build Scripts

```json
{
  "scripts": {
    "build:js": "esbuild app/js/*.* --bundle --sourcemap --format=esm --outdir=app/assets/builds --inject:./inject-jquery.js --public-path=/assets",
    "build:css": "tailwindcss -i ./app/assets/stylesheets/active_admin_source.css -o ./app/assets/stylesheets/active_admin_compiled.css",
    "build": "npm run build:js && npm run build:css && cp app/assets/builds/active_admin.js app/assets/javascripts/trumbowyg_bundle.js",
    "watch:js": "npm run build:js -- --watch",
    "watch:css": "npm run build:css -- --watch"
  }
}
```

Note the key differences:
- Uses `--format=esm` instead of `--format=iife`
- Uses `--inject:./inject-jquery.js` to properly inject jQuery
- Pattern `app/js/*.*` to build all JS files

### 5. JavaScript Source (app/js/active_admin.js)

```javascript
// jQuery is injected globally via inject-jquery.js
import $ from 'jquery';
import 'trumbowyg';

// Ensure jQuery is available globally for other scripts
window.$ = window.jQuery = $;

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

$(document).ready(initTrumbowygEditors);
$(document).on('has_many_add:after', '.has_many_container', initTrumbowygEditors);
$(document).on('turbo:load turbolinks:load', initTrumbowygEditors);

console.log('Trumbowyg initialized with esbuild');
```

### 5. Sprockets Loader (app/assets/javascripts/trumbowyg_loader.js)

```javascript
//= require ./trumbowyg_bundle

(function() {
  function waitForJQuery(callback) {
    if (typeof window.jQuery !== 'undefined' && window.jQuery.fn && window.jQuery.fn.trumbowyg) {
      callback(window.jQuery);
    } else {
      setTimeout(function() { waitForJQuery(callback); }, 50);
    }
  }
  
  function initEditors($) {
    $('[data-aa-trumbowyg]').each(function () {
      var $element = $(this);
      if (!$element.hasClass('trumbowyg-textarea--active')) {
        var options = { svgPath: '/assets/trumbowyg/icons.svg' };
        var dataOptions = $element.data('options');
        if (dataOptions) {
          options = $.extend({}, options, dataOptions);
        }
        $element.trumbowyg(options);
        $element.addClass('trumbowyg-textarea--active');
      }
    });
  }
  
  document.addEventListener('DOMContentLoaded', function() {
    waitForJQuery(function($) {
      initEditors($);
      $(document).on('has_many_add:after', '.has_many_container', function() {
        initEditors($);
      });
      $(document).on('turbo:load turbolinks:load', function() {
        initEditors($);
      });
    });
  });
})();
```

### 6. Sprockets Manifest (app/assets/javascripts/active_admin.js)

```javascript
//= require ./trumbowyg_loader
```

### 7. CSS Setup

Create symlink to Trumbowyg CSS from npm (proper asset pipeline integration):
```bash
ln -sf ../../../../node_modules/trumbowyg/dist/ui/trumbowyg.css app/assets/stylesheets/trumbowyg.css
```

Main CSS file (app/assets/stylesheets/active_admin.css):
```css
/*
 *= require ./active_admin_compiled
 *= require ./trumbowyg
 *= require activeadmin/_trumbowyg_input
 */
```

**Note**: Using a symlink ensures the CSS is properly served from node_modules through the Rails asset pipeline without copying files.

Tailwind source (app/assets/stylesheets/active_admin_source.css):
```css
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Trumbowyg overrides for Tailwind compatibility */
.trumbowyg-box {
  @apply border border-gray-300 rounded-md;
}

.trumbowyg-editor {
  @apply min-h-[200px] p-3;
}

.dark .trumbowyg-box {
  @apply border-gray-600;
}

.dark .trumbowyg-button-pane {
  @apply bg-gray-800 border-gray-600;
}

.dark .trumbowyg-editor {
  @apply bg-gray-900 text-gray-100;
}

.trumbowyg-button-pane button {
  @apply hover:bg-gray-100 dark:hover:bg-gray-700;
}

.trumbowyg-button-pane button svg {
  fill: currentColor !important;
}
```

### 8. Set Up Assets

```bash
# Create symlink for CSS (don't copy!)
ln -sf ../../../../node_modules/trumbowyg/dist/ui/trumbowyg.css app/assets/stylesheets/trumbowyg.css

# Copy icons (these need to be in public)
cp node_modules/trumbowyg/dist/ui/icons.svg public/assets/trumbowyg/

# Build everything
npm run build
```

### 9. ActiveAdmin Form Configuration

```ruby
ActiveAdmin.register Post do
  permit_params :title, :description, :body, :author_id

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :title
      f.input :author
      f.input :description, as: :text, input_html: { 
        class: 'trumbowyg-input', 
        'data-aa-trumbowyg': true 
      }
      f.input :body, as: :text, input_html: { 
        class: 'trumbowyg-input', 
        'data-aa-trumbowyg': true 
      }
    end
    f.actions
  end
end
```

## Key Points

1. **No register_javascript**: ActiveAdmin 4 doesn't support this anymore
2. **Use esbuild with inject pattern**: The `inject-jquery.js` file is CRITICAL for proper jQuery handling
3. **ESM format with inject**: Use `--format=esm` with `--inject:./inject-jquery.js` 
4. **Copy to Sprockets**: After building, copy bundle to javascripts/
5. **Wait for jQuery**: Use polling to ensure jQuery loads before initializing
6. **Data attributes**: Use `data-aa-trumbowyg` to mark textareas for initialization

## Why the inject-jquery.js Pattern?

This pattern (documented in https://github.com/evanw/esbuild/issues/1681) ensures that:
1. jQuery is available as both `$` and `jQuery` in all bundled modules
2. jQuery plugins like Trumbowyg can properly attach to jQuery
3. The build works correctly in both development and production
4. No conflicts with other jQuery instances on the page

## Troubleshooting

- **jQuery not defined**: Make sure you have the `inject-jquery.js` file and use `--inject:./inject-jquery.js` in esbuild
- **Icons not showing**: Ensure icons.svg is copied to public/assets/trumbowyg/
- **Styles not loading**: Check that Trumbowyg CSS is included in Sprockets manifest
- **Editor not initializing**: Check browser console for errors, ensure JavaScript is loading

## Build Command for Deployment

```bash
cd spec/internal
npm run build
# Assets are now ready for Rails asset precompilation
```

This setup works with ActiveAdmin 4's new architecture while maintaining compatibility with the gem's requirements.