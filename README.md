# Active Admin Trumbowyg (Rocket Sensei Fork)

[![CI](https://github.com/glebtv/activeadmin_trumbowyg/actions/workflows/ci.yml/badge.svg)](https://github.com/glebtv/activeadmin_trumbowyg/actions/workflows/ci.yml)
[![NPM Version](https://img.shields.io/npm/v/@rocket-sensei/activeadmin_trumbowyg)](https://www.npmjs.com/package/@rocket-sensei/activeadmin_trumbowyg)

**Note:** This is the Rocket Sensei fork of activeadmin_trumbowyg, providing full ActiveAdmin 4 and Rails 8 support.

An *Active Admin* plugin to use [Trumbowyg](https://alex-d.github.io/Trumbowyg/) as WYSIWYG editor in form inputs.

Features:
- Fast & lightweight rich editor for Active Admin
- Customizable options via data attributes
- Plugin support (image upload, emoji, etc.)
- Dark mode support for ActiveAdmin 4
- Automatic NPM package publishing on new releases

### Light Mode
![Light Mode](extra/light-mode.png)

### Dark Mode
![Dark Mode](extra/dark-mode.png)

Please :star: if you like it.

## Version 2.0 - ActiveAdmin 4 Support

This version is designed for **ActiveAdmin 4.x with modern JavaScript bundlers** (esbuild/webpack). 

- **ActiveAdmin 4.x**: Use version 2.x of this gem
- **ActiveAdmin 1.x - 3.x**: Use version 1.x of this gem

### Requirements

- Ruby >= 3.2
- Rails >= 7.0
- ActiveAdmin ~> 4.0.0.beta
- Modern JavaScript bundler (esbuild or webpack)
- Propshaft for asset management (included in Rails 8, add manually for Rails 7)

**Note:** This gem is specifically designed for ActiveAdmin 4 with modern JavaScript bundlers. Sprockets is not supported.

## Install

### Step 1: Add the gem

Add to your Gemfile:

```ruby
gem 'rs-activeadmin_trumbowyg', '~> 4.0.3'

# For Rails 7, also add Propshaft (Rails 8 includes it by default):
gem 'propshaft' # Required for Rails 7
```

Then run `bundle install`.

### Step 2: Install JavaScript package and configure

ActiveAdmin 4 uses modern JavaScript bundlers. Choose your setup:

#### For esbuild or webpack (recommended)

1. Install the NPM packages:
```bash
npm install @rocket-sensei/activeadmin_trumbowyg jquery trumbowyg
```

2. Import and configure in your `app/javascript/active_admin.js`:
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

3. Copy Trumbowyg assets (icons and CSS) for Propshaft:
```bash
# Add these to your package.json scripts section:
"copy:trumbowyg-icons": "mkdir -p app/assets/builds && cp node_modules/trumbowyg/dist/ui/icons.svg app/assets/builds/icons.svg",
"copy:trumbowyg-css": "cp node_modules/trumbowyg/dist/ui/trumbowyg.min.css app/assets/builds/trumbowyg.css",
"build:assets": "npm run copy:trumbowyg-icons && npm run copy:trumbowyg-css"

# Then run:
npm run build:assets
```

**Note for Rails with Propshaft:** The icons.svg file needs to be accessible via HTTP. The default path is `/icons.svg` but you can configure it by setting `window.TRUMBOWYG_SVG_PATH` before calling `setupAutoInit()`. In production, Propshaft will serve files from `app/assets/builds/` with digest paths. You may need to configure the path based on your deployment setup.

4. Add Trumbowyg styles to `app/assets/stylesheets/active_admin.css`:
```css
/* Import Trumbowyg styles - the exact path depends on your asset pipeline setup */
/* For Propshaft/esbuild, the CSS will be in app/assets/builds/ */
@import 'trumbowyg.css';

/* Custom Trumbowyg input styles */
.trumbowyg-box {
  margin: 0;
}

.trumbowyg-editor {
  min-height: 200px;
}
```

**Note:** The icons.svg and trumbowyg.css files are copied from the npm package to your assets/builds directory. These files should be added to .gitignore as they're generated during the build process:

```gitignore
# Ignore generated Trumbowyg assets
app/assets/builds/icons.svg
app/assets/builds/trumbowyg.css
```

#### For importmap

Importmap users need manual configuration as it doesn't support NPM packages:

1. Run the installation generator:
```bash
rails generate active_admin:trumbowyg:install --bundler=importmap
```

This will:
- Add pins to your `config/importmap.rb`
- Copy vendor JavaScript files
- Add Trumbowyg styles to your ActiveAdmin stylesheet

### Step 3: Use in your forms

```ruby
ActiveAdmin.register Article do
  form do |f|
    f.inputs 'Article' do
      f.input :title
      f.input :description, as: :trumbowyg
      f.input :published
    end
    f.actions
  end
end
```

### Step 4: Production setup

For production environments, simply deploy as usual. All assets are handled automatically through the NPM package or CDN.

## Usage

### Basic usage

```ruby
form do |f|
  f.inputs 'Article' do
    f.input :title
    f.input :description, as: :trumbowyg
    f.input :published
  end
  f.actions
end
```

### With custom options

The **data-options** attribute allows you to pass Trumbowyg configuration directly. For reference see [options list](https://alex-d.github.io/Trumbowyg/documentation/).

```ruby
f.input :description, as: :trumbowyg, input_html: { 
  data: { 
    options: { 
      btns: [
        ['bold', 'italic'], 
        ['superscript', 'subscript'], 
        ['link'], 
        ['justifyLeft', 'justifyCenter', 'justifyRight', 'justifyFull'], 
        ['unorderedList', 'orderedList'], 
        ['horizontalRule'], 
        ['removeformat']
      ] 
    } 
  } 
}
```

## Plugins

### Upload plugin

Plugin reference [here](https://alex-d.github.io/Trumbowyg/documentation/plugins/#plugin-upload).

Add to your JavaScript file (after importing trumbowyg):

```javascript
import 'trumbowyg/dist/plugins/upload/trumbowyg.upload.js';
```

Form field config:

```ruby
unless resource.new_record?
  f.input :description, as: :trumbowyg, input_html: { 
    data: { 
      options: { 
        btns: [['bold', 'italic'], ['link'], ['upload']], 
        plugins: { 
          upload: { 
            serverPath: upload_admin_post_path(resource.id), 
            fileFieldName: 'file_upload' 
          } 
        } 
      } 
    } 
  }
end
```

Upload action (using ActiveStorage):

```ruby
member_action :upload, method: [:post] do
  result = { success: resource.images.attach(params[:file_upload]) }
  result[:file] = url_for(resource.images.last) if result[:success]
  render json: result
end
```

For a complete upload example, see [examples/upload_plugin_using_activestorage/](examples/upload_plugin_using_activestorage/).

## Migration from version 1.x

If upgrading from version 1.x:

1. Update Ruby to >= 3.2 and Rails to >= 7.0
2. Update to ActiveAdmin 4.x
3. Remove old asset pipeline configurations:
   - Remove `//= require activeadmin/trumbowyg/trumbowyg` from `active_admin.js`
   - Remove `//= require activeadmin/trumbowyg_input` from `active_admin.js`
   - Remove `@import 'activeadmin/trumbowyg/trumbowyg';` from `active_admin.scss`
   - Remove `@import 'activeadmin/trumbowyg_input';` from `active_admin.scss`
4. Install the NPM package and import it (for esbuild/webpack) or run the generator (for importmap) - see Step 2 above

## Troubleshooting

### Trumbowyg not initializing

Make sure jQuery and Trumbowyg are loaded before the initialization script. Check your browser console for errors.

### Icons not showing

Ensure you're using the correct version of Trumbowyg from NPM. Icons are embedded in the CSS from the NPM package.

### Custom plugins not working

Ensure you're importing the plugin JavaScript files after the main Trumbowyg library.

## Changelog

The changelog is available [here](CHANGELOG.md).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/glebtv/activeadmin_trumbowyg.

## Development

For development information please check [this document](extra/development.md).

### NPM Package Publishing

The JavaScript portion of this gem is automatically published to NPM as `@rocket-sensei/activeadmin_trumbowyg` when a new version tag is created. This happens through GitHub Actions CI/CD pipeline.

### Migration from Original Gem

If you're using the original `activeadmin_trumbowyg` gem, please see our [Migration Guide](docs/guide-update-your-app.md) for detailed upgrade instructions.

## Do you like it? Star it!

If you use this component just star it. A developer is more motivated to improve a project when there is some interest. My other [Active Admin components](https://github.com/blocknotes?utf8=✓&tab=repositories&q=activeadmin&type=source).

Or consider offering me a coffee, it's a small thing but it is greatly appreciated: [about me](https://www.blocknot.es/about-me).

## License

The gem is available as open-source under the terms of the [MIT](LICENSE.txt).