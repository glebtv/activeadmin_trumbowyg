# ActiveAdmin 4 + Trumbowyg: Complete Working Solution

## Overview
This document contains the complete, tested solution for integrating Trumbowyg WYSIWYG editor with ActiveAdmin 4 using Tailwind CSS and the esbuild-based asset pipeline.

## Problem Statement
ActiveAdmin 4 requires:
- Tailwind CSS v3 with ActiveAdmin plugin
- Modern JavaScript bundling (esbuild/webpack)
- Proper integration of vendor CSS (Trumbowyg) with Tailwind

## The Working Solution

### 1. Core Dependencies
```json
// spec/internal/package.json
{
  "dependencies": {
    "esbuild": "^0.24.2",
    "jquery": "^3.7.1",
    "trumbowyg": "^2.28.0"
  },
  "devDependencies": {
    "@activeadmin/activeadmin": "^3.3.0",
    "tailwindcss": "^3.4.17"
  }
}
```

### 2. Tailwind Configuration with Safelist (CRITICAL!)
```javascript
// spec/internal/tailwind.config.mjs
import activeAdminPlugin from '@activeadmin/activeadmin/plugin'
import { execSync } from 'node:child_process'

let activeAdminPath = null
try {
  activeAdminPath = execSync('bundle show activeadmin', { encoding: 'utf8' }).trim()
} catch (e) {
  // If bundler is unavailable at build time, we still build without scanning AA views
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
  theme: {
    extend: {},
  },
  plugins: [activeAdminPlugin],
  safelist: [
    // CRITICAL: Without this safelist, ActiveAdmin layout breaks!
    // Grid and layout
    'grid', 'gap-4', 'gap-6', 'lg:grid-cols-3', 'md:grid-cols-2', 
    'col-span-2', 'col-span-3', 'lg:col-span-2', 'lg:col-span-1',
    // Flexbox
    'flex', 'flex-col', 'flex-row', 'flex-wrap', 'items-center', 'justify-between',
    'justify-center', 'items-start', 'items-end',
    // Spacing
    'p-4', 'p-6', 'px-4', 'px-6', 'py-2', 'py-4', 'm-0', 'mx-auto', 'mt-4', 'mb-4',
    'ml-auto', 'mr-auto', 'space-y-4', 'space-x-4',
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
    // Position
    'relative', 'absolute', 'fixed', 'sticky', 'top-0', 'left-0', 'right-0',
    // Z-index
    'z-10', 'z-20', 'z-30', 'z-40', 'z-50'
  ]
}
```

### 3. CSS Build Script (Concatenates Trumbowyg CSS)
```javascript
// spec/internal/build_css.js
#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const root = __dirname;
const inputPath = path.join(root, 'app/assets/stylesheets/active_admin_source.css');
const vendorCssPath = path.join(root, 'node_modules/trumbowyg/dist/ui/trumbowyg.css');
const tmpPath = path.join(root, 'app/assets/stylesheets/__aa_tmp.css');
const outPath = path.join(root, 'app/assets/builds/active_admin.css');

function build() {
  const src = fs.readFileSync(inputPath, 'utf8').split(/\r?\n/);
  const vendorCss = fs.readFileSync(vendorCssPath, 'utf8');

  const tailwindDirectives = [
    '@tailwind base;',
    '@tailwind components;',
    '@tailwind utilities;'
  ].join('\n');

  const bodyLines = src.slice(3).filter(line => !line.includes('trumbowyg.css'));
  const body = bodyLines.join('\n');

  const tmpCss = `${tailwindDirectives}\n\n/* Begin Trumbowyg vendor CSS */\n${vendorCss}\n/* End Trumbowyg vendor CSS */\n\n${body}\n`;
  fs.writeFileSync(tmpPath, tmpCss, 'utf8');

  // Run tailwindcss build
  const res = spawnSync('npx', [
    'tailwindcss',
    '-c', path.join(root, 'tailwind.config.mjs'),
    '-i', tmpPath,
    '-o', outPath
  ], { stdio: 'inherit', cwd: root });

  if (res.status !== 0) {
    process.exit(res.status);
  }

  fs.unlinkSync(tmpPath);
}

build();
```

### 4. Package.json Scripts
```json
{
  "scripts": {
    "build:css": "node ./build_css.js",
    "build:js": "esbuild app/js/*.* --bundle --sourcemap --format=esm --outdir=app/assets/builds --inject:./inject-jquery.js --public-path=/assets --loader:.css=file",
    "build": "npm run build:js && npm run build:css"
  }
}
```

### 5. jQuery Injection (CRITICAL for esbuild!)
```javascript
// spec/internal/inject-jquery.js
// https://github.com/evanw/esbuild/issues/1681
export { default as $ } from 'jquery/dist/jquery.js'
export { default as jQuery } from 'jquery/dist/jquery.js'
```

### 6. JavaScript Entry Point
```javascript
// spec/internal/app/js/active_admin.js
import $ from 'jquery';
import 'trumbowyg';

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
```

### 7. Source CSS with Overrides
```css
// spec/internal/app/assets/stylesheets/active_admin_source.css
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Trumbowyg CSS is concatenated by build_css.js */

/* Custom overrides for Trumbowyg + Tailwind compatibility */
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
```

### 8. Assets Setup
```bash
# From spec/internal directory:

# 1. Install dependencies
npm install

# 2. Create symlink for icons (critical for toolbar icons!)
mkdir -p app/assets/trumbowyg
ln -sf ../../../node_modules/trumbowyg/dist/ui/icons.svg app/assets/trumbowyg/icons.svg

# 3. Build assets
npm run build

# 4. Verify build output
ls -lah app/assets/builds/active_admin.css
# Should be > 100KB with safelist + Trumbowyg + ActiveAdmin styles
```

### 9. Rails Asset Manifest
```javascript
// spec/internal/app/assets/config/manifest.js
//= link_tree ../builds
//= link trumbowyg/icons.svg
```

### 10. ActiveAdmin Form Usage
```ruby
# spec/internal/app/admin/posts.rb
ActiveAdmin.register Post do
  permit_params :title, :description, :body, :author_id

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :title
      f.input :author
      f.input :description, as: :text, input_html: { 
        'data-aa-trumbowyg': true 
      }
      f.input :body, as: :text, input_html: { 
        'data-aa-trumbowyg': true,
        'data-options': { 
          btns: [
            ['viewHTML'],
            ['undo', 'redo'],
            ['formatting'],
            ['strong', 'em', 'del'],
            ['link'],
            ['insertImage'],
            ['justifyLeft', 'justifyCenter', 'justifyRight'],
            ['unorderedList', 'orderedList'],
            ['horizontalRule'],
            ['removeformat'],
            ['fullscreen']
          ]
        }.to_json
      }
    end
    f.actions
  end
end
```

## Testing

### Start the Server
```bash
cd /data/activeadmin_trumbowyg
bundle exec rackup
# Visit http://localhost:9292/admin/posts/new
```

### Success Indicators
✅ ActiveAdmin layout with proper styling (navigation, forms, buttons)
✅ Trumbowyg editors with visible toolbar icons
✅ CSS file > 100KB with both Tailwind utilities and Trumbowyg styles
✅ No JavaScript errors in console
✅ Icons load from `/assets/trumbowyg/icons.svg`

## Key Insights

1. **Safelist is CRITICAL**: Without the safelist in Tailwind config, ActiveAdmin's dynamic classes won't be generated
2. **Build script concatenation**: Tailwind CLI doesn't inline npm CSS imports properly, so we concatenate manually
3. **jQuery injection pattern**: Essential for esbuild to properly expose jQuery globally
4. **ESM format**: Use `--format=esm` with esbuild, not IIFE
5. **Icons symlink**: Toolbar icons must be accessible at `/assets/trumbowyg/icons.svg`

## Common Issues & Solutions

### Issue: Page has no styling
**Solution**: Add safelist to `tailwind.config.mjs` and rebuild CSS

### Issue: Trumbowyg toolbar has no icons
**Solution**: Create symlink to icons.svg and add to manifest.js

### Issue: CSS file too small (<50KB)
**Solution**: Check that build_css.js is concatenating Trumbowyg CSS properly

### Issue: jQuery not defined errors
**Solution**: Ensure inject-jquery.js exists and is referenced in esbuild command

## Next Steps for Other Gems
Use this pattern for the ~20 other ActiveAdmin extension gems:
1. Copy the build configuration (tailwind.config.mjs with safelist)
2. Adapt the build_css.js for the specific vendor CSS needs
3. Use the same jQuery injection pattern if the gem uses jQuery plugins
4. Test thoroughly with both light and dark modes