# ActiveAdmin Trumbowyg 2.x Migration Guide

## Overview
This guide covers migrating from activeadmin_trumbowyg 1.x to 2.x, which adds support for ActiveAdmin 4 and modern JavaScript build tools. Version 2.x introduces a new NPM package for easier integration with esbuild and webpack projects.

## What's New in Version 2.x

### NPM Package Support
- Published on NPM as `@rocket-sensei/activeadmin_trumbowyg`
- Direct integration with esbuild and webpack projects
- No generator needed for modern JavaScript bundlers
- Automatic jQuery dependency management

### Path Changes
- JavaScript module paths changed from `activeadmin/` to `active_admin/`
- CSS paths updated to follow Rails conventions

### Compatibility
- ActiveAdmin 3.x and 4.x support
- Rails 7.0+ required
- Ruby 3.2+ required
- Works with both Sprockets (legacy) and Propshaft

## Installation Methods

### Option 1: Modern JavaScript Bundlers (esbuild/webpack) - Recommended

#### Install the NPM package:
```bash
npm install @rocket-sensei/activeadmin_trumbowyg
# or
yarn add @rocket-sensei/activeadmin_trumbowyg
```

#### Import in your JavaScript entry point:
```javascript
// app/javascript/active_admin.js or similar
import '@rocket-sensei/activeadmin_trumbowyg'
```

That's it! No generator needed. The package automatically handles jQuery dependencies and initialization.

### Option 2: Sprockets/Importmap (Legacy)

#### Add to Gemfile:
```ruby
gem 'activeadmin_trumbowyg', '~> 2.0'
```

#### Run the generator:
```bash
rails generate activeadmin_trumbowyg:install
```

This will add the necessary JavaScript and CSS to your ActiveAdmin configuration.

## Migration from Version 1.x to 2.x

### Step 1: Update Your Gemfile
```ruby
# Old (1.x)
gem 'activeadmin_trumbowyg', '~> 1.0'

# New (2.x)
gem 'activeadmin_trumbowyg', '~> 2.0'
```

### Step 2: Update JavaScript Paths

If you're using esbuild or webpack, switch to the NPM package:

```javascript
// Old (1.x) - Using gem assets
//= require activeadmin/trumbowyg/trumbowyg
//= require activeadmin/trumbowyg_input

// New (2.x) - Using NPM package
import '@rocket-sensei/activeadmin_trumbowyg'
```

For Sprockets users, update the paths:

```javascript
// Old (1.x)
//= require activeadmin/trumbowyg/trumbowyg
//= require activeadmin/trumbowyg_input

// New (2.x)
//= require active_admin/trumbowyg/trumbowyg
//= require active_admin/trumbowyg_input
```

### Step 3: Update CSS Imports

```css
/* Old (1.x) */
@import "activeadmin/trumbowyg/trumbowyg";

/* New (2.x) */
@import "active_admin/trumbowyg/trumbowyg";
```

## Configuration Examples

### esbuild Configuration

```javascript
// esbuild.config.js
import esbuild from 'esbuild'

esbuild.build({
  entryPoints: ['app/javascript/active_admin.js'],
  bundle: true,
  sourcemap: true,
  format: 'esm',
  outdir: 'app/assets/builds',
  loader: {
    '.js': 'jsx',
  },
  external: [], // jQuery is bundled by the NPM package
})
```

### webpack Configuration

```javascript
// webpack.config.js
module.exports = {
  entry: './app/javascript/active_admin.js',
  output: {
    path: path.resolve(__dirname, 'app/assets/builds'),
    filename: 'active_admin.js'
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: 'babel-loader'
      }
    ]
  }
}
```

### Package.json Example

```json
{
  "name": "your-app",
  "dependencies": {
    "@rocket-sensei/activeadmin_trumbowyg": "^2.0.0",
    "jquery": "^3.7.1"
  },
  "scripts": {
    "build": "esbuild app/javascript/*.* --bundle --sourcemap --outdir=app/assets/builds"
  }
}
```

## Usage in ActiveAdmin

After installation, use the Trumbowyg editor in your admin forms:

```ruby
# app/admin/posts.rb
ActiveAdmin.register Post do
  form do |f|
    f.inputs do
      f.input :title
      f.input :content, as: :trumbowyg
      # With options
      f.input :description, as: :trumbowyg, input_html: {
        data: {
          trumbowyg_options: {
            btns: [
              ['viewHTML'],
              ['formatting'],
              ['strong', 'em', 'del'],
              ['link'],
              ['insertImage'],
              ['unorderedList', 'orderedList'],
              ['horizontalRule'],
              ['removeformat'],
              ['fullscreen']
            ],
            minimalLinks: true,
            removeformatPasted: true
          }
        }
      }
    end
    f.actions
  end
end
```

## Customizing Trumbowyg

### Custom Buttons and Plugins

The NPM package includes all Trumbowyg plugins. To use them:

```javascript
// app/javascript/active_admin.js
import '@rocket-sensei/activeadmin_trumbowyg'

// Custom initialization (optional)
document.addEventListener('DOMContentLoaded', () => {
  // Custom global defaults
  $.trumbowyg.svgPath = '/assets/icons.svg'
  
  // Language settings
  $.trumbowyg.langs.en.bold = 'Strong'
})
```

### Styling the Editor

Add custom styles in your ActiveAdmin stylesheet:

```scss
// app/assets/stylesheets/active_admin.scss
@import "active_admin/trumbowyg/trumbowyg";

// Custom overrides
.trumbowyg-box {
  margin: 0;
  
  .trumbowyg-editor {
    min-height: 300px;
  }
}

// Dark mode support
.dark {
  .trumbowyg-box {
    background: #374151;
    
    .trumbowyg-editor {
      background: #1f2937;
      color: #f3f4f6;
    }
  }
}
```

## Troubleshooting

### Common Issues and Solutions

#### Issue: Trumbowyg not initializing
**Solution**: Ensure jQuery is loaded before the Trumbowyg package:
```javascript
// Correct order
import $ from 'jquery'
window.$ = window.jQuery = $
import '@rocket-sensei/activeadmin_trumbowyg'
```

#### Issue: Icons not displaying
**Solution**: The SVG path might be incorrect. Set it explicitly:
```javascript
$.trumbowyg.svgPath = '/assets/trumbowyg/icons.svg'
```

#### Issue: Styles not loading with NPM package
**Solution**: Import the CSS separately in your stylesheet:
```css
/* app/assets/stylesheets/active_admin.scss */
@import "@rocket-sensei/activeadmin_trumbowyg/dist/trumbowyg.min.css";
```

#### Issue: Editor not working in nested forms
**Solution**: Re-initialize after adding new fields:
```javascript
$(document).on('has_many_add:after', '.has_many_container', function() {
  $(this).find('[data-trumbowyg]').each(function() {
    if (!$(this).hasClass('trumbowyg-textarea-init')) {
      const options = $(this).data('trumbowyg-options') || {}
      $(this).trumbowyg(options)
    }
  })
})
```

## Breaking Changes from 1.x

1. **Path changes**: All paths changed from `activeadmin/` to `active_admin/`
2. **NPM package**: New recommended installation method via NPM
3. **No generator for modern bundlers**: esbuild/webpack users don't need the generator
4. **jQuery handling**: NPM package bundles jQuery dependencies automatically

## Version Compatibility

| activeadmin_trumbowyg | ActiveAdmin | Rails | Ruby |
|-----------------------|-------------|-------|------|
| 2.x                   | 3.x - 4.x   | 7.0+  | 3.2+ |
| 1.x                   | 1.x - 3.x   | 5.2+  | 2.5+ |

## Resources

- [NPM Package](https://www.npmjs.com/package/@rocket-sensei/activeadmin_trumbowyg)
- [GitHub Repository](https://github.com/rocket-sensei/activeadmin_trumbowyg)
- [Trumbowyg Documentation](https://alex-d.github.io/Trumbowyg/)
- [ActiveAdmin Documentation](https://activeadmin.info/)

## Support

For issues or questions:
1. Check the [GitHub Issues](https://github.com/rocket-sensei/activeadmin_trumbowyg/issues)
2. Consult the [Trumbowyg documentation](https://alex-d.github.io/Trumbowyg/) for editor-specific questions
3. For ActiveAdmin 4 specific issues, see the [ActiveAdmin upgrade guide](https://activeadmin.info/)