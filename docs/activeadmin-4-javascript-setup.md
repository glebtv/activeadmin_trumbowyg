# ActiveAdmin 4 JavaScript Setup with Esbuild

## Overview
ActiveAdmin 4 uses importmap-rails by default, but we can integrate esbuild-built JavaScript bundles using Sprockets.

## Setup Steps

### 1. Install Dependencies
```bash
cd spec/internal
npm install jquery trumbowyg esbuild
```

### 2. Create Build Scripts in package.json
```json
{
  "scripts": {
    "build:js": "esbuild app/js/active_admin.js --bundle --sourcemap --format=esm --outdir=app/assets/builds --public-path=/assets",
    "build:css": "tailwindcss -i ./app/assets/stylesheets/active_admin_source.css -o ./app/assets/stylesheets/active_admin_compiled.css",
    "build": "npm run build:js && npm run build:css",
    "watch:js": "npm run build:js -- --watch",
    "watch:css": "npm run build:css -- --watch",
    "watch": "npm run build:js -- --watch & npm run build:css -- --watch"
  }
}
```

### 3. Create JavaScript Entry Point
Create `app/js/active_admin.js`:
```javascript
// Import jQuery and make it global
import $ from 'jquery';
window.$ = window.jQuery = $;

// Import Trumbowyg
import 'trumbowyg';

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

### 4. Build JavaScript
```bash
npm run build:js
```

### 5. Copy Bundle to Sprockets Assets
```bash
cp app/assets/builds/active_admin.js app/assets/javascripts/trumbowyg_bundle.js
```

### 6. Create Sprockets Loader
Create `app/assets/javascripts/trumbowyg_loader.js`:
```javascript
//= require ./trumbowyg_bundle

document.addEventListener('DOMContentLoaded', function() {
  if (typeof window.jQuery !== 'undefined' && window.jQuery.fn.trumbowyg) {
    var $ = window.jQuery;
    
    function initEditors() {
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
    
    initEditors();
    $(document).on('has_many_add:after', '.has_many_container', initEditors);
    $(document).on('turbo:load turbolinks:load', initEditors);
  }
});
```

### 7. Include in ActiveAdmin Manifest
Update `app/assets/javascripts/active_admin.js`:
```javascript
//= require ./trumbowyg_loader
```

## Alternative: Direct Importmap Integration

If you want to use importmap directly:

1. Pin the module in `config/importmap.rb`:
```ruby
pin "trumbowyg_init", to: "trumbowyg_init.js", preload: true
```

2. Import in `app/javascript/active_admin.js`:
```javascript
import "trumbowyg_init"
```

3. Create `app/javascript/trumbowyg_init.js` with initialization code.

## Assets Required
- Copy Trumbowyg CSS to `app/assets/stylesheets/`
- Copy icons.svg to `public/assets/trumbowyg/`
- Include CSS in Tailwind build or Sprockets manifest

## Complete Build Command
```bash
npm run build && cp app/assets/builds/active_admin.js app/assets/javascripts/trumbowyg_bundle.js
```

This can be added to your deployment process or Rails asset precompilation.