# ActiveAdmin 4 Extension Gem Migration Guide

## Overview
This guide provides a proven pattern for migrating ActiveAdmin extension gems to support ActiveAdmin 4. Based on successful migration of activeadmin_trumbowyg and activeadmin-searchable_select gems.

## Quick Checklist
- [ ] Update Ruby requirement to >= 3.2
- [ ] Update Rails requirement to >= 7.0  
- [ ] Update ActiveAdmin dependency to support 4.x
- [ ] Set up Combustion test app with proper loading order
- [ ] Configure Tailwind with ActiveAdmin plugin and safelist
- [ ] Build vendor CSS into Tailwind output
- [ ] Set up esbuild for JavaScript with jQuery injection
- [ ] Update CSS selectors (`.filter_form` → `.filters-form`)
- [ ] Test with both light and dark modes

## Step 1: Update Dependencies

### Gemspec
```ruby
spec.required_ruby_version = '>= 3.2'
spec.add_runtime_dependency 'activeadmin', ['>= 1.x', '< 5']
```

### Gemfile (for development)
```ruby
gem 'combustion'
gem 'importmap-rails', '~> 2.0'  # Required for ActiveAdmin 4
```

## Step 2: Set Up Combustion Test App

### Critical: Loading Order in config.ru
```ruby
# config.ru - MUST control loading order for ActiveAdmin!
require "rubygems"
require "bundler"

# DON'T use Bundler.require - it loads gems too early!
Bundler.setup(:default, :development)

# Load Rails and combustion first
require 'combustion'

# Initialize Combustion with Rails components
Combustion.initialize! :active_record, :action_controller, :action_view do
  config.load_defaults Rails::VERSION::STRING.to_f if Rails::VERSION::MAJOR >= 7
end

# NOW load ActiveAdmin after Rails is initialized
require 'importmap-rails'
require 'active_admin'
require 'your_gem'

# Critical: Explicitly require custom inputs after everything else
require 'formtastic/inputs/your_custom_input' if defined?(Formtastic)

run Combustion::Application
```

## Step 3: Asset Pipeline Configuration

### Directory Structure
```
spec/internal/
├── app/
│   ├── assets/
│   │   ├── builds/           # Output directory
│   │   │   └── active_admin.css
│   │   ├── config/
│   │   │   └── manifest.js
│   │   └── stylesheets/
│   │       └── active_admin_source.css
│   └── js/
│       └── active_admin.js   # Source JavaScript
├── package.json
├── tailwind.config.mjs       # ESM format
├── build_css.js              # Build script
└── inject-jquery.js          # jQuery injection for esbuild
```

### Package.json
```json
{
  "name": "internal",
  "scripts": {
    "build:css": "node ./build_css.js",
    "build:js": "esbuild app/js/*.* --bundle --sourcemap --format=esm --outdir=app/assets/builds --inject:./inject-jquery.js --public-path=/assets",
    "build": "npm run build:js && npm run build:css"
  },
  "dependencies": {
    "esbuild": "^0.24.2",
    "jquery": "^3.7.1",
    "your-vendor-package": "^x.x.x"
  },
  "devDependencies": {
    "@activeadmin/activeadmin": "^3.3.0",
    "tailwindcss": "^3.4.17"
  }
}
```

## Step 4: Tailwind Configuration (CRITICAL!)

### tailwind.config.mjs with Safelist
```javascript
import activeAdminPlugin from '@activeadmin/activeadmin/plugin'
import { execSync } from 'node:child_process'

let activeAdminPath = null
try {
  activeAdminPath = execSync('bundle show activeadmin', { encoding: 'utf8' }).trim()
} catch (e) {
  // Build continues without scanning AA views if bundler unavailable
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
    // Position & Z-index
    'relative', 'absolute', 'fixed', 'sticky', 'top-0', 'left-0', 'right-0',
    'z-10', 'z-20', 'z-30', 'z-40', 'z-50',
    // Shadows
    'shadow', 'shadow-md', 'shadow-lg'
  ]
}
```

## Step 5: CSS Build Script (for vendor CSS)

### build_css.js
```javascript
#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const root = __dirname;
const inputPath = path.join(root, 'app/assets/stylesheets/active_admin_source.css');
const vendorCssPath = path.join(root, 'node_modules/your-package/dist/styles.css');
const tmpPath = path.join(root, 'app/assets/stylesheets/__aa_tmp.css');
const outPath = path.join(root, 'app/assets/builds/active_admin.css');

function build() {
  const src = fs.readFileSync(inputPath, 'utf8');
  const vendorCss = fs.readFileSync(vendorCssPath, 'utf8');

  // Ensure Tailwind directives are first
  const tailwindDirectives = '@tailwind base;\n@tailwind components;\n@tailwind utilities;';
  
  // Remove any vendor imports from source
  const cleanedSrc = src.replace(/@import.*your-package.*;/g, '');
  
  // Combine: Tailwind -> Vendor CSS -> Custom overrides
  const tmpCss = `${tailwindDirectives}\n\n/* Vendor CSS */\n${vendorCss}\n\n/* Custom */\n${cleanedSrc}`;
  
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
}

build();
```

## Step 6: jQuery Plugin Pattern

### inject-jquery.js (Critical for esbuild!)
```javascript
// https://github.com/evanw/esbuild/issues/1681
export { default as $ } from 'jquery/dist/jquery.js'
export { default as jQuery } from 'jquery/dist/jquery.js'
```

### JavaScript Entry Point
```javascript
// app/js/active_admin.js
import $ from 'jquery';
import 'your-jquery-plugin';

// Ensure jQuery is global
window.$ = window.jQuery = $;

// Initialize your plugin
function initPlugin() {
  $('[data-your-plugin]').each(function () {
    if (!$(this).hasClass('plugin-active')) {
      const options = $(this).data('options') || {};
      $(this).yourPlugin(options);
      $(this).addClass('plugin-active');
    }
  });
}

// Initialize on various events
$(document).ready(initPlugin);
$(document).on('has_many_add:after', '.has_many_container', initPlugin);
$(document).on('turbo:load turbolinks:load', initPlugin);
```

## Step 7: CSS Selector Updates

| ActiveAdmin 3.x | ActiveAdmin 4.x |
|----------------|-----------------|
| `.filter_form` | `.filters-form` |
| `.tabs` | Removed - use divs |
| `.columns` | Use Tailwind grid |

## Step 8: Testing Setup

### ActiveAdmin Initializer
```ruby
# spec/internal/config/initializers/active_admin.rb
ActiveAdmin.setup do |config|
  config.site_title = "Test App"
  config.authentication_method = false
  config.current_user_method = false
end
```

### Build and Test
```bash
cd spec/internal
npm install
npm run build
cd ../..
bundle exec rackup
# Visit http://localhost:9292/admin
```

## Success Indicators
✅ CSS file > 100KB (with safelist + vendor CSS)  
✅ No unstyled elements on admin pages
✅ jQuery plugins working without console errors
✅ Vendor CSS properly integrated
✅ Dark mode working

## Common Pitfalls & Solutions

### Pitfall: ActiveAdmin layout broken
**Solution**: Add safelist to tailwind.config.mjs

### Pitfall: Vendor CSS not loading
**Solution**: Use build_css.js to concatenate before Tailwind

### Pitfall: jQuery not defined
**Solution**: Use inject-jquery.js with esbuild

### Pitfall: Formtastic input not found
**Solution**: Explicitly require in config.ru after ActiveAdmin

### Pitfall: CSS too small (<50KB)
**Solution**: Check safelist and vendor CSS concatenation

## CI/CD Configuration

```yaml
# .github/workflows/ci.yml
name: CI
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        ruby: ['3.2', '3.3']
        rails: ['7.0', '7.1', '7.2', '8.0']
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby }}
          bundler-cache: true
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: |
          cd spec/internal
          npm install
          npm run build
      - run: bundle exec rspec
```

## Publishing NPM Package (Optional)

```json
{
  "name": "@activeadmin/your-gem",
  "version": "1.0.0",
  "main": "src/index.js",
  "module": "src/index.js",
  "exports": {
    ".": "./src/index.js",
    "./css": "./src/styles.css"
  },
  "peerDependencies": {
    "jquery": ">= 3.0",
    "your-vendor-dep": "^x.x.x"
  }
}
```

## Summary
The key to successful ActiveAdmin 4 migration is:
1. Proper Combustion loading order (config.ru)
2. Tailwind safelist for dynamic classes
3. Vendor CSS concatenation before Tailwind processing
4. jQuery injection pattern for esbuild
5. Updated CSS selectors

This pattern has been proven on multiple gems and provides a reliable foundation for the remaining ~20 gems to be updated.