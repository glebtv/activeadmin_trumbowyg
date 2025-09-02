# Migration Guide: Updating to rs-activeadmin_trumbowyg

This guide will help you migrate from the original `activeadmin_trumbowyg` gem to our forked and updated version `rs-activeadmin_trumbowyg`.

## Why Update?

Our fork provides:
- ✅ Full ActiveAdmin 4.0 support
- ✅ Rails 8 and Propshaft compatibility
- ✅ Modern JavaScript bundler support (esbuild/webpack)
- ✅ Proper NPM package distribution
- ✅ Fixed icon serving issues
- ✅ No CDN dependencies - all assets served locally

## Migration Steps

### Step 1: Update your Gemfile

Replace the old gem with our fork:

```ruby
# Remove this:
# gem 'activeadmin_trumbowyg'

# Add this:
gem 'rs-activeadmin_trumbowyg', '~> 4.0.3'

# For Rails 7, also ensure you have Propshaft:
gem 'propshaft' # Rails 8 includes this by default
```

Then run:
```bash
bundle install
```

### Step 2: Update JavaScript Dependencies

Remove old packages and install the new ones:

```bash
# Remove old packages if present
npm uninstall activeadmin_trumbowyg

# Install new packages
npm install @rocket-sensei/activeadmin_trumbowyg jquery trumbowyg
```

### Step 3: Update JavaScript Imports

Update your `app/javascript/active_admin.js`:

```javascript
// Import jQuery and make it globally available (required by Trumbowyg)
import $ from 'jquery';
window.$ = window.jQuery = $;

// Import Trumbowyg
import 'trumbowyg';

// Import and setup ActiveAdmin Trumbowyg
import { setupAutoInit } from '@rocket-sensei/activeadmin_trumbowyg';

// Optional: Configure the SVG icons path (default is '/icons.svg')
// window.TRUMBOWYG_SVG_PATH = '/assets/icons.svg';

setupAutoInit();
```

### Step 4: Setup Asset Copying

Add these scripts to your `package.json`:

```json
{
  "scripts": {
    "copy:trumbowyg-icons": "mkdir -p app/assets/builds && cp node_modules/trumbowyg/dist/ui/icons.svg app/assets/builds/icons.svg",
    "copy:trumbowyg-css": "cp node_modules/trumbowyg/dist/ui/trumbowyg.min.css app/assets/builds/trumbowyg.css",
    "build:assets": "npm run copy:trumbowyg-icons && npm run copy:trumbowyg-css && esbuild app/javascript/*.* --bundle --sourcemap --outdir=app/assets/builds"
  }
}
```

Run the asset build:
```bash
npm run build:assets
```

### Step 5: Update Stylesheets

In your `app/assets/stylesheets/active_admin.css`:

```css
/* Import Trumbowyg styles */
@import 'trumbowyg.css';

/* Custom Trumbowyg input styles */
.trumbowyg-box {
  margin: 0;
}

.trumbowyg-editor {
  min-height: 200px;
}
```

### Step 6: Add to .gitignore

Add generated assets to `.gitignore`:

```gitignore
# Ignore generated Trumbowyg assets
app/assets/builds/icons.svg
app/assets/builds/trumbowyg.css
```

### Step 7: Configure Asset Pipeline (if needed)

For development environments, you might need to copy icons to the public directory:

```bash
# For development only
cp app/assets/builds/icons.svg public/icons.svg
```

Or add to your build script:
```json
"build:dev": "npm run build:assets && cp app/assets/builds/icons.svg public/icons.svg"
```

## Troubleshooting

### Icons Not Showing

If icons aren't displaying:

1. Check that `icons.svg` is accessible at the configured path
2. Try setting a custom path:
   ```javascript
   window.TRUMBOWYG_SVG_PATH = '/assets/icons.svg';
   ```
3. Ensure the file is copied during your build process

### Styles Not Loading

1. Verify that `trumbowyg.css` is in `app/assets/builds/`
2. Check that your stylesheet includes the import
3. Restart your Rails server after changes

### JavaScript Errors

1. Ensure jQuery is loaded before Trumbowyg
2. Check that all NPM packages are installed
3. Verify your bundler configuration includes the correct paths

## Version Compatibility

- **Ruby**: >= 3.2
- **Rails**: >= 7.0
- **ActiveAdmin**: ~> 4.0.0.beta
- **Node.js**: >= 18.0

## Need Help?

If you encounter issues:
1. Check that all build steps completed successfully
2. Clear your browser cache
3. Restart your Rails server
4. Check the browser console for errors

For bug reports or questions, please visit:
https://github.com/glebtv/activeadmin_trumbowyg/issues