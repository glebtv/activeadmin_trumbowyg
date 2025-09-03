# Session Continuation Notes - ActiveAdmin Gems Standardization

## Current Status
Working on standardizing two ActiveAdmin gems:
- `/data/activeadmin_trumbowyg` (rs-activeadmin_trumbowyg) - **FULLY WORKING v4.0.4** ✅
  - Fixed critical CSS bundling issue using Tailwind CLI
  - All CSS loading tests passing (4/4) ✅
  - Updated tests to check for ActiveAdmin 4's actual HTML structure
  - Fixed CI workflow to build and extract npm package (avoids vendor symlink issues)
- `/data/activeadmin-searchable_select` (rs-activeadmin-searchable_select) - Needs updates ⚠️

## Completed Tasks
1. ✅ Fixed CI failures for both gems
2. ✅ Standardized NPM package structure
3. ✅ Forked both gems with new names (rs- prefix)
4. ✅ Published NPM packages:
   - `@rocket-sensei/activeadmin_trumbowyg@4.0.4`
   - `@rocket-sensei/activeadmin-searchable_select@4.0.2`
5. ✅ Updated documentation for ActiveAdmin 4 and Propshaft
6. ✅ Both gems support ActiveAdmin 4.0.0.beta only
7. ✅ Fixed jQuery loading issues with proper module exports
8. ✅ Set up proper NPM package imports instead of esbuild aliases
9. ✅ Created NPM scripts to copy both icons.svg and CSS from trumbowyg package
10. ✅ Added generated assets to .gitignore
11. ✅ Removed Tailwind dependencies and simplified CSS build
12. ✅ Fixed assets to be served locally via Propshaft (no CDN)
13. ✅ **FIXED CSS BUILD** - Now using Tailwind CLI with ActiveAdmin plugin
   - Created `tailwind-active_admin.config.js` based on production app `/data/rslogin-ui/`
   - Created `build_activeadmin_css.js` to properly bundle CSS
   - CSS now includes: Tailwind base + Trumbowyg vendor CSS + custom styles
   - Build command: `npm run build:css:activeadmin`
   - Updated CSS loading tests to check for ActiveAdmin 4's actual HTML structure
   - All CSS loading tests now passing (was checking for old `#header` instead of new Tailwind classes)
14. ✅ **FIXED CI WORKFLOW** - Build and extract npm package to avoid vendor symlink issues
   - Build npm package with `npm pack`
   - Extract to `/tmp/npm-package`
   - Install from extracted package instead of `file:../..`
   - Completely avoids RSpec discovering vendor/bundle specs through symlinks

## NEXT SESSION: Fix activeadmin-searchable_select

### Main Issues to Fix
1. **Test app needs Propshaft setup** (currently partially configured)
   - File: `spec/internal/config/environment.rb` - Changed to use `:propshaft` ✅
   - Still needs proper asset loading configuration

2. **Test failures** - 1 test failing:
   ```
   spec/features/inline_ajax_setting_spec.rb:25 
   # inline_ajax_options setting when ajax option set to true renders all options statically
   ```
   - Issue: JavaScript not loading properly in test environment
   - The helper in `spec/internal/config/initializers/active_admin.rb` loads from `src/searchable_select/init.js`

3. **Module namespace issues** (partially fixed):
   - Fixed in: `lib/activeadmin/inputs/searchable_select_input.rb`
   - Fixed in: `lib/activeadmin/inputs/filters/searchable_select_input.rb`
   - Changed from `SearchableSelect::SelectInputExtension` to `ActiveAdmin::SearchableSelect::SelectInputExtension`

### Test App Configuration Needed

#### Current searchable_select test app structure:
```
spec/internal/
├── app/
│   └── assets/
│       ├── builds/.keep (created)
│       └── javascripts/
│           ├── active_admin.js (Sprockets syntax - needs update)
│           └── searchable_select_test.js (placeholder)
├── config/
│   ├── environment.rb (updated to use Propshaft ✅)
│   └── initializers/
│       ├── active_admin.rb (loads JS via helper - needs review)
│       └── assets.rb (Sprockets config - needs update)
└── (no package.json, no esbuild config)
```

#### CI Workflow Fix for searchable_select
**CRITICAL**: Must use same approach as trumbowyg to avoid vendor/bundle symlink issues:
1. Build npm package with `npm pack`
2. Extract to `/tmp/npm-package`  
3. Install from extracted package in test app
4. See: `/data/activeadmin_trumbowyg/.github/workflows/ci.yml` lines 68-87

### What searchable_select needs (adapt from trumbowyg):
1. **esbuild.config.js** - Create based on `/data/activeadmin_trumbowyg/spec/internal/esbuild.config.js`
   - Change alias from `'activeadmin_trumbowyg'` to `'activeadmin-searchable_select'`
   - Point to `'../../src/index.js'`

2. **package.json** - Create based on `/data/activeadmin_trumbowyg/spec/internal/package.json`
   - Keep: esbuild, @activeadmin/activeadmin, jquery
   - Add: select2 (instead of trumbowyg)
   - Remove: trumbowyg, tailwindcss, @tailwindcss/forms

3. **inject-jquery.js** - Copy `/data/activeadmin_trumbowyg/spec/internal/inject-jquery.js` as-is

4. **app/js/active_admin.js** - Create based on `/data/activeadmin_trumbowyg/spec/internal/app/js/active_admin.js`
   - Import activeadmin-searchable_select instead of activeadmin_trumbowyg

### Security Issues Fixed in trumbowyg

1. **Removed from trumbowyg** (unnecessary complexity):
   - ✅ `spec/internal/build_css.js` - Removed
   - ✅ `spec/internal/tailwind.config.mjs` - Removed
   - ✅ Simplified to just copy CSS from npm package

### Latest Fixes in trumbowyg (Session 2)

1. **Icon serving fixed**:
   - ✅ Icons now copied to both `app/assets/builds/` and `public/`
   - ✅ Configurable SVG path via `window.TRUMBOWYG_SVG_PATH`
   - ✅ Works with Propshaft in production and development

2. **Documentation created**:
   - ✅ Migration guide at `docs/guide-update-your-app.md`
   - ✅ README updated with correct paths and instructions
   - ✅ Clear Propshaft configuration documented

2. **Docker setup** (low priority):
   - `/data/activeadmin_trumbowyg/extra/` directory
   - Safe but consider removing if not needed

### Key Files to Reference from activeadmin_trumbowyg

#### Working test app files to use as templates:
- `/data/activeadmin_trumbowyg/spec/internal/esbuild.config.js` - Working esbuild config
- `/data/activeadmin_trumbowyg/spec/internal/package.json` - Package dependencies for test app
- `/data/activeadmin_trumbowyg/spec/internal/inject-jquery.js` - jQuery injection helper
- `/data/activeadmin_trumbowyg/spec/internal/app/js/active_admin.js` - Working JS entry point
- **NEW**: `/data/activeadmin_trumbowyg/spec/internal/tailwind-active_admin.config.js` - Tailwind config with ActiveAdmin plugin
- **NEW**: `/data/activeadmin_trumbowyg/spec/internal/build_activeadmin_css.js` - CSS build script
- `/data/activeadmin_trumbowyg/spec/rails_helper.rb` - Test configuration
- `/data/activeadmin_trumbowyg/spec/internal/config/initializers/active_admin.rb` - ActiveAdmin config
- `/data/activeadmin_trumbowyg/spec/internal/config/initializers/assets.rb` - Asset configuration
- `/data/activeadmin_trumbowyg/spec/internal/config/initializers/trumbowyg.rb` - Gem-specific config

#### Files REMOVED from trumbowyg (security warnings):
- ✅ `/data/activeadmin_trumbowyg/spec/internal/build_css.js` - Deleted
- ✅ `/data/activeadmin_trumbowyg/spec/internal/tailwind.config.mjs` - Deleted

#### Broken test file from searchable_select:
- `spec/internal/config/initializers/active_admin.rb` (lines 56-63):
  ```ruby
  def add_searchable_select_js(content)
    content << '<script type="text/javascript">'
    js_file_path = File.expand_path(
      '../../../../src/searchable_select/init.js', __dir__
    )
    content << File.read(js_file_path)
    content << '</script>'
  end
  ```

### Testing Commands
```bash
# Test searchable_select
cd /data/activeadmin-searchable_select
bundle exec rspec spec/features/inline_ajax_setting_spec.rb

# Test trumbowyg (all passing)
cd /data/activeadmin_trumbowyg
bundle exec rspec --fail-fast
```

### Key Decisions Made
1. **No Sprockets support** - Only Propshaft for ActiveAdmin 4
2. **Minimal test app setup** - Remove Tailwind/CSS build complexity
3. **Standardize on esbuild** for JavaScript in test apps
4. **Both gems must have identical structure** for maintainability

### Important Notes
- The `src/` directory in both gems contains the actual JavaScript code
- Test apps should use the actual NPM package (`@rocket-sensei/activeadmin_trumbowyg`) via `file:../..` in package.json
- Icons.svg must be copied from node_modules using NPM scripts (not committed to repo)
- The gem exports proper ES modules with `setupAutoInit()` function
- jQuery must be made global BEFORE importing Trumbowyg
- Both gems already have proper NPM package configuration
- The Ruby gem parts are working, just need test app fixes

### Key Changes Made to activeadmin_trumbowyg
1. **Module Structure**: Changed from auto-initializing to exporting functions (`setupAutoInit`)
2. **Package Reference**: Test app uses `"@rocket-sensei/activeadmin_trumbowyg": "file:../.."`
3. **Icon Handling**: Icons copied via NPM script, not stored in repo
4. **Build Process**: `npm run build` now includes `copy:icons` step

### Version Info
- activeadmin_trumbowyg: **4.0.4 FULLY WORKING** ✅
  - Gem: `rs-activeadmin_trumbowyg`
  - NPM: `@rocket-sensei/activeadmin_trumbowyg`
  - All CSS loading tests passing (4/4)
  - Icons served correctly from `/trumbowyg/icons.svg`
  - CSS properly bundled with Tailwind + ActiveAdmin plugin + Trumbowyg
  - Documentation updated
  - CI workflow fixed to build/extract npm package (avoids vendor symlinks)
- activeadmin-searchable_select: 4.0.2 (needs similar updates)
  - Gem: `rs-activeadmin-searchable_select`
  - NPM: `@rocket-sensei/activeadmin-searchable_select`
  - Needs: Tailwind CSS build, CI workflow fix, test app setup