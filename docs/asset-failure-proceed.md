# ActiveAdmin 4 Asset Pipeline Fix - Complete Instructions

## Current Problem Status
The activeadmin_trumbowyg gem has been partially updated for ActiveAdmin 4 support, but the asset pipeline is misconfigured:

1. **CSS Build Location Mismatch**: 
   - CSS builds to: `app/assets/stylesheets/active_admin_compiled.css`
   - But Rails serves from: `app/assets/builds/active_admin.css`
   
2. **Trumbowyg CSS Not Loading**: The Trumbowyg editor CSS from npm package isn't being included in the build

3. **Multiple Duplicate Configs**: Too many Tailwind configuration files exist

## Working Reference Structure
From a working ActiveAdmin 4 app provided by user:
```
app/assets/
├── builds/
│   ├── active_admin.css      # <- CSS should build here
│   ├── active_admin.css.map
│   ├── active_admin.js       # <- JS builds here correctly
│   ├── active_admin.js.map
│   ├── application.js
│   ├── application.js.map
│   └── tailwind.css
├── config/
│   ├── active_admin_manifest.js
│   └── manifest.js
├── images/
├── javascripts/
│   └── admin/
└── stylesheets/
    ├── active_admin.css       # <- Sprockets manifest file
    ├── admin/
    ├── application.tailwind.css
    ├── trumbowyg_bundle.css
    └── _trumbowyg_input.css
```

## Key Files to Check/Modify

### 1. Build Configuration
**Path**: `/data/activeadmin_trumbowyg/spec/internal/package.json`
```json
{
  "scripts": {
    "build:js": "esbuild app/js/*.* --bundle --sourcemap --format=esm --outdir=app/assets/builds --inject:./inject-jquery.js --public-path=/assets --loader:.css=file",
    "build:css": "tailwindcss -i ./app/assets/stylesheets/active_admin_source.css -o ./app/assets/builds/active_admin.css",  // <- NEEDS FIX
    "build": "npm run build:js && npm run build:css"
  }
}
```

### 2. CSS Source File
**Path**: `/data/activeadmin_trumbowyg/spec/internal/app/assets/stylesheets/active_admin_source.css`
- Must import Trumbowyg CSS from node_modules
- Must import gem's Trumbowyg input styles

### 3. Sprockets Manifest
**Path**: `/data/activeadmin_trumbowyg/spec/internal/app/assets/stylesheets/active_admin.css`
```css
/*
 *= require ./active_admin_compiled  
 *= require ./trumbowyg
 *= require activeadmin/_trumbowyg_input
 */
```

### 4. Tailwind Configs to Clean Up
- `/data/activeadmin_trumbowyg/spec/internal/tailwind.config.js` (keep this one)
- `/data/activeadmin_trumbowyg/spec/internal/tailwind.config.mjs` (delete)
- `/data/activeadmin_trumbowyg/spec/internal/config/tailwind.config.js` (delete)
- `/data/activeadmin_trumbowyg/spec/internal/config/tailwind-active_admin.config.js` (delete or fix module issues)

### 5. jQuery Injection Pattern
**Path**: `/data/activeadmin_trumbowyg/spec/internal/inject-jquery.js`
```javascript
// https://github.com/evanw/esbuild/issues/1681
export { default as $ } from 'jquery/dist/jquery.js'
export { default as jQuery } from 'jquery/dist/jquery.js'
```

### 6. Main JavaScript Entry
**Path**: `/data/activeadmin_trumbowyg/spec/internal/app/js/active_admin.js`

## Steps to Fix

### Step 1: Clean up Tailwind configs
1. Delete duplicate configs
2. Keep only one simple `tailwind.config.js` in `/spec/internal/`

### Step 2: Fix CSS build output location
1. Update `package.json` build:css script to output to `app/assets/builds/active_admin.css`
2. Remove the intermediate `active_admin_compiled.css` reference

### Step 3: Include Trumbowyg CSS properly
1. Update `active_admin_source.css` to import:
   - `@import '../../../../node_modules/trumbowyg/dist/ui/trumbowyg.css';`
   - `@import '../../../../../app/assets/stylesheets/activeadmin/_trumbowyg_input.scss';`

### Step 4: Fix Sprockets manifest
1. Update `/spec/internal/app/assets/stylesheets/active_admin.css` to point to the correct built file

### Step 5: Test the build
```bash
cd /data/activeadmin_trumbowyg/spec/internal
npm run build:css
# Check that file exists at app/assets/builds/active_admin.css
# Check that it includes Trumbowyg styles
```

## Important Context
- ActiveAdmin 4 uses importmap-rails for JavaScript (not Sprockets)
- ActiveAdmin 4 uses Tailwind CSS v3 with a custom plugin
- The test app uses Combustion gem for Rails engine testing
- The gem needs to work with esbuild (user explicitly requested this)
- User has ~20 more gems to update with this same pattern

## Previous Error Context
- ActiveAdmin plugin module not found error when using `@activeadmin/activeadmin/plugin`
- Consider using a simpler Tailwind config without the plugin if it continues to fail
- The symlink approach for Trumbowyg CSS (`ln -sf` to node_modules) was attempted but user wants proper asset pipeline integration

## Success Criteria
1. CSS builds to `app/assets/builds/active_admin.css`
2. Trumbowyg editor styles are visible when rendered
3. No duplicate Tailwind configs
4. Clean, repeatable setup documented for other gems

## User's Key Feedback Points
- "we're not supposed to copy it, it's supposed to be properly used in asset pipeline from npm"
- "far too many tailwinds configs. Lets make sure we clean this mess up."
- Referenced working setup from `/data/activeadmin-searchable_select` as a good example

## Additional Critical Details

### Exact Package Versions Used
```json
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

### ActiveAdmin Version
- Using `activeadmin-4.0.0.beta16` 
- This version uses importmap-rails for JS (NOT Sprockets)
- `register_javascript` method no longer exists in AA4

### Test Server Details
- Start server: `cd /data/activeadmin_trumbowyg/spec/internal && rackup`
- Test URL: http://localhost:9292/
- Admin pages have Trumbowyg editor fields that should be styled

### Known Error Messages
1. "Cannot find module '@activeadmin/activeadmin/plugin'" - ActiveAdmin Tailwind plugin not properly installed
2. "jQuery is not defined" - Fixed with inject-jquery.js pattern
3. CSS file served but empty/missing Trumbowyg styles

### File Digest Issue
Rails serves CSS with digest: `active_admin-0972eb4a71193426163fe2762cb0ab7ffd7f84ca5d04d0cb080ad3f3fb16cf90.css`
This is the digested version of `active_admin.css`

### Gem Asset Locations
- Gem's Trumbowyg input styles: `/data/activeadmin_trumbowyg/app/assets/stylesheets/activeadmin/_trumbowyg_input.scss`
- Gem's JS wrapper: `/data/activeadmin_trumbowyg/vendor/assets/javascripts/activeadmin-trumbowyg.js`
- NPM Trumbowyg CSS: `node_modules/trumbowyg/dist/ui/trumbowyg.css`
- NPM Trumbowyg icons: `node_modules/trumbowyg/dist/ui/icons.svg`

### Working Build Output Example
When correctly configured, `npm run build:css` should:
1. Read from `app/assets/stylesheets/active_admin_source.css`
2. Process through Tailwind
3. Include Trumbowyg styles from npm
4. Output to `app/assets/builds/active_admin.css`
5. File should be ~150-200KB (includes Tailwind + Trumbowyg)

### Visual Success Indicator
When working correctly, the Trumbowyg editor should show:
- Toolbar with formatting buttons (bold, italic, etc.)
- Bordered text area
- Icons visible in toolbar buttons
- Proper hover states on buttons

### Combustion Gem Context
- Test app is in `/data/activeadmin_trumbowyg/spec/internal/`
- This is a Rails engine testing setup
- Full Rails app structure but minimal configuration
- Uses `config.ru` to start the test app

### Esbuild jQuery Pattern Explanation
The inject-jquery.js pattern solves: https://github.com/evanw/esbuild/issues/1681
- Esbuild doesn't automatically expose jQuery globally
- Many jQuery plugins expect `window.$` and `window.jQuery`
- The inject pattern ensures jQuery is available globally for all modules

### ActiveAdmin 4 JavaScript Loading
- Uses `Rails.application.config.importmap` for JS management
- JavaScript files must be in ESM format
- No more Sprockets //= require directives for JS
- JS files are loaded via `<script type="module">` tags

### Files That Should NOT Be Edited
- Anything in `/data/activeadmin/` (separate gem)
- Files in `node_modules/` (managed by npm)
- The main gem files unless specifically needed

### Debug Commands
```bash
# Check if CSS was built correctly
ls -la /data/activeadmin_trumbowyg/spec/internal/app/assets/builds/

# See what CSS is actually being served
curl -s http://localhost:9292/assets/active_admin.css | head -20

# Check for Trumbowyg classes in built CSS
grep -c "trumbowyg" /data/activeadmin_trumbowyg/spec/internal/app/assets/builds/active_admin.css

# Verify npm packages installed
ls -la /data/activeadmin_trumbowyg/spec/internal/node_modules/ | grep trumbowyg
```

### Common Pitfalls
1. Don't use IIFE format for esbuild - use ESM format
2. Don't copy npm files - reference them properly
3. Don't use multiple Tailwind configs - confuses the build
4. Don't forget the inject-jquery.js for esbuild
5. Remember ActiveAdmin 4 doesn't use Sprockets for JS anymore

### Asset Pipeline Flow for ActiveAdmin 4
```
CSS Pipeline (Still uses Sprockets):
1. active_admin_source.css (Tailwind source with @imports)
   ↓ npm run build:css (Tailwind CLI)
2. app/assets/builds/active_admin.css (compiled output)
   ↓ Sprockets
3. Served with digest as /assets/active_admin-[hash].css

JS Pipeline (Uses importmap-rails):
1. app/js/active_admin.js (ESM source)
   ↓ esbuild with inject-jquery.js
2. app/assets/builds/active_admin.js (bundled ESM)
   ↓ importmap-rails
3. Served as module script
```

### Manifest Files Content
**app/assets/config/manifest.js** should contain:
```javascript
//= link_tree ../builds
```

### Browser DevTools Checks
1. Network tab: Check active_admin-[hash].css loads (should be ~150KB+)
2. Console: No jQuery undefined errors
3. Elements: Trumbowyg should have classes like `trumbowyg-box`, `trumbowyg-editor`
4. Styles: Check computed styles show Trumbowyg CSS rules applied

### HTML Structure When Working
```html
<div class="field">
  <label for="post_body">Body</label>
  <div class="trumbowyg-box trumbowyg-fullscreen-mode">
    <div class="trumbowyg-button-pane">
      <!-- toolbar buttons here -->
    </div>
    <div class="trumbowyg-editor" contenteditable="true">
      <!-- editor content -->
    </div>
  </div>
  <textarea id="post_body" data-aa-trumbowyg style="display: none;"></textarea>
</div>
```

### Git Files Modified (from git status)
- Modified files that should be kept:
  - `Gemfile` (ActiveAdmin 4 update)
  - `lib/activeadmin/trumbowyg/engine.rb`
  - `lib/formtastic/inputs/trumbowyg_input.rb`
  - `vendor/assets/javascripts/activeadmin-trumbowyg.js`

- New files created for AA4 support:
  - `spec/internal/` directory (entire Combustion test app)
  - `config.ru` (for rackup)
  - Various documentation files

### Alternative Approaches if Main Fix Fails

#### Option 1: Simple CSS concatenation
```bash
cat node_modules/trumbowyg/dist/ui/trumbowyg.css > app/assets/builds/trumbowyg.css
cat app/assets/stylesheets/activeadmin/_trumbowyg_input.scss >> app/assets/builds/trumbowyg.css
# Then require in manifest
```

#### Option 2: Use PostCSS instead of Tailwind CLI
```json
{
  "scripts": {
    "build:css": "postcss app/assets/stylesheets/active_admin_source.css -o app/assets/builds/active_admin.css"
  }
}
```

#### Option 3: Skip Tailwind plugin, use vanilla Tailwind
Create minimal tailwind.config.js without ActiveAdmin plugin

### Performance Expectations
- CSS build time: 500-1000ms
- JS build time: 100-300ms  
- Built CSS size: ~150-200KB (with Tailwind + Trumbowyg)
- Built JS size: ~300-400KB (jQuery + Trumbowyg + wrapper)

### Production Considerations
For production deployment:
```ruby
# config/environments/production.rb
config.assets.compile = false
config.assets.precompile += %w[ active_admin.js active_admin.css ]
```

### Testing the Final Fix
```bash
# Full rebuild
cd /data/activeadmin_trumbowyg/spec/internal
rm -rf app/assets/builds/*
npm run build

# Start server
rackup

# In another terminal, check assets
curl -I http://localhost:9292/assets/active_admin.css
# Should return 200 OK

# Check for Trumbowyg styles
curl -s http://localhost:9292/assets/active_admin.css | grep -o "trumbowyg" | head -5
# Should show multiple matches

# Visit admin page with editor
# http://localhost:9292/admin/posts/new
# Should see styled WYSIWYG editor
```

### Rails Environment Details
- Rails version: 8.0.0 (from Gemfile)
- Ruby version: 3.2.2+
- Bundler: Using local gem path for activeadmin_trumbowyg
- Server: Rackup/Puma

### Configuration Dependencies
The setup depends on these configs working together:
1. `package.json` scripts must output to correct directories
2. `tailwind.config.js` must process the CSS correctly
3. Sprockets manifest must link to built files
4. Rails asset pipeline must serve from app/assets/builds/

### Related Documentation Links
- [Rails 7 Asset Pipeline Guide](https://discuss.rubyonrails.org/t/guide-to-rails-7-and-the-asset-pipeline/80851)
- [Esbuild jQuery injection issue](https://github.com/evanw/esbuild/issues/1681)
- [ActiveAdmin 4 migration guide](https://github.com/activeadmin/activeadmin/blob/master/CHANGELOG.md)
- Working example: `/data/activeadmin-searchable_select` gem