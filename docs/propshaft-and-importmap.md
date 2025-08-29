# ActiveAdmin Trumbowyg with Propshaft and Importmap

This document explains how to integrate ActiveAdmin Trumbowyg with Rails applications using Propshaft and importmap-rails.

## Installation Options

### Option 1: Using Importmap (Recommended for vanilla Rails)

For Rails applications using importmap-rails, you can use the provided generator or manually configure the integration:

#### Using the Generator

```bash
rails generate active_admin:trumbowyg:install
```

This will:
1. Pin the necessary JavaScript modules to your importmap configuration
2. Configure ActiveAdmin to use Trumbowyg as the default editor
3. Set up the correct asset paths

#### Manual Setup

If you prefer manual configuration, add the following to your `config/importmap.rb`:

```ruby
# Pin Trumbowyg editor assets
pin "active_admin/trumbowyg", to: "active_admin/trumbowyg.js"
pin "active_admin/trumbowyg/editor", to: "active_admin/trumbowyg/editor.js"
```

Then configure ActiveAdmin in `config/initializers/active_admin.rb`:

```ruby
ActiveAdmin.setup do |config|
  # Set Trumbowyg as the default editor
  config.default_editor = :trumbowyg
end
```

### Option 2: Using NPM Package (For esbuild/webpack users)

If you're using esbuild, webpack, or other JavaScript bundlers, install the NPM package instead:

```bash
npm install @rocket-sensei/activeadmin_trumbowyg
# or
yarn add @rocket-sensei/activeadmin_trumbowyg
```

Then import it in your JavaScript entry point:

```javascript
import '@rocket-sensei/activeadmin_trumbowyg'
```

## Important Path Changes

**Note:** In recent versions, JavaScript asset paths have been updated from `activeadmin/` to `active_admin/` for consistency with Rails conventions. If upgrading from an older version, update your importmap pins accordingly.

## Asset Pipeline Integration

### With Propshaft

ActiveAdmin Trumbowyg provides its JavaScript assets through the standard Rails asset pipeline. When using Propshaft:

1. **Asset Location**: JavaScript files are located in `app/assets/javascripts/active_admin/`
2. **Fingerprinting**: Propshaft automatically digests and fingerprints the files
3. **Serving**: Assets are served from the public folder with cache-friendly URLs

### With Importmap

The gem integrates seamlessly with importmap-rails:

1. **Module Mapping**: The importmap configuration maps module names to actual asset files
2. **Preloading**: JavaScript modules are automatically preloaded for better performance
3. **No Bundling Required**: Uses native ES modules, no build step needed

### Asset Organization

The gem follows Rails conventions with updated paths:
- Main module: `active_admin/trumbowyg.js`
- Editor module: `active_admin/trumbowyg/editor.js`
- Stylesheets: Automatically included via ActiveAdmin's asset pipeline

## Troubleshooting

### Common Issues

1. **Assets not loading**: Ensure you've run `rails assets:precompile` in production
2. **Module not found errors**: Check that your importmap pins use the correct `active_admin/` prefix
3. **Editor not initializing**: Verify that ActiveAdmin's default editor is set to `:trumbowyg`

### Upgrading from Previous Versions

If upgrading from a version that used `activeadmin/` paths:

```ruby
# Old (incorrect)
pin "activeadmin/trumbowyg", to: "activeadmin/trumbowyg.js"

# New (correct)
pin "active_admin/trumbowyg", to: "active_admin/trumbowyg.js"
```

## Understanding Propshaft and Importmap

The following sections explain how **Propshaft + importmap-rails** work together. These gems have **zero overlap in functionality** and are perfectly complementary.

With growing frustration, I realized one final approach remained. It can be hard and time consuming but it absolutely always works.

[![Show me the code!](https://radanskoric.com/assets/img/posts/show_me_the_code.jpg)](https://radanskoric.com/assets/img/posts/show_me_the_code.jpg)

Looking at the source code always works.

Thankfully, as of the time of writing this article Propshaft source stands at 659 lines of Ruby and importmap rails stands at 584 lines of Ruby. Total of 1242 lines of Ruby. That’s _suprisingly_ managable. I’ve reviewed larger single feature PRs<sup id="fnref:1"><a href="https://radanskoric.com/articles/rails-assets-propshaft-importmaps#fn:1" rel="footnote" role="doc-noteref">1</a></sup>.

So, I read all of the code. It answered all my questions. _Maybe I should have done that first._

## Rails Asset Pipeline Background

First, a very quick recap of the key points from the modern Rails asset pipeline. This is essential for understanding how ActiveAdmin Trumbowyg integrates with your Rails application.

### What is Propshaft?[](https://radanskoric.com/articles/rails-assets-propshaft-importmaps#what-is-propshaft)

Propshaft gem is the latest iteration of the Rails asset processing pipeline, inheriting Sprockets. It is much simpler than its predecessors. Built from scratch for simplicity, it accomplishes this by doing less and relying on the modern browser support and wide adoption of HTTP/2 to do the rest.

If you’re interested, you can read more about the transition from Sprockets in the [Rails’ guide to the asset pipeline](https://guides.rubyonrails.org/asset_pipeline.html#sprockets-to-propshaft).

### What is importmap-rails?[](https://radanskoric.com/articles/rails-assets-propshaft-importmaps#what-is-importmap-rails)

I’m assuming you’re familiar with the `import` statement [available in javascript modules](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/import). It allows you to import javascript functionality from a different module file for use in the current one.

However, this typically requires providing URLs to the other JavaScript module sources. **Importmaps** are a way to avoid specifying the full location of the source and instead use a shorter name. This increases readability and allows us to move files, e.g. to a CDN, without rewriting the `import` statements.

Importmap is a script tag of type `importmap` and defines a mapping from a name to the location, i.e.:

`<table><tbody><tr><td><pre>1 2 3 4 5 6 </pre></td><td><pre><span>&lt;script </span><span>type=</span><span>"importmap"</span><span>&gt;</span><span>{</span>   <span>"</span><span>imports</span><span>"</span><span>:</span> <span>{</span>     <span>"</span><span>foo</span><span>"</span><span>:</span> <span>"</span><span>/assets/modules/foo-f13jf4.js</span><span>"</span><span>,</span>     <span>"</span><span>bar</span><span>"</span><span>:</span> <span>"</span><span>https://example.com/module-bar-ahd3f5.js</span><span>"</span><span>,</span>   <span>}</span> <span>}</span><span>&lt;/script&gt;</span> </pre></td></tr></tbody></table>`

Given this importmap we could now use `import * from "foo"` and `import * from "bar"` and the browser will figure out the locations of the source files from importmaps.

You can also tell the browser to preload modules so they’re already loaded when needed using a `modulepreload` link tag:

`<table><tbody><tr><td><pre>1 </pre></td><td><pre><span>&lt;link</span> <span>rel=</span><span>"modulepreload"</span> <span>href=</span><span>"/assets/modules/foo-f13jf4.js"</span><span>&gt;</span> </pre></td></tr></tbody></table>`

**importmap-rails** gem provides helpers for defining and generating the relevant `script` tags.

## How ActiveAdmin Trumbowyg Uses the Pipeline

ActiveAdmin Trumbowyg leverages both Propshaft and importmap-rails to deliver its assets:

### Gem-based Asset Distribution

The gem includes JavaScript files in its `app/assets/javascripts/active_admin/` directory. This follows the Rails convention where gems can provide assets by including them in their `app/assets` folder.

### Integration Points

1. **Asset Registration**: The gem's engine automatically adds its asset paths to `Rails.configuration.assets.paths`
2. **Importmap Configuration**: The install generator adds the necessary pins to your `config/importmap.rb`
3. **ActiveAdmin Integration**: The editor hooks into ActiveAdmin's form builder system

### Dual Distribution Strategy

ActiveAdmin Trumbowyg supports two distribution methods:

1. **Ruby Gem + Importmap**: For vanilla Rails applications using importmap-rails
2. **NPM Package**: For applications using JavaScript bundlers (esbuild, webpack)

This dual approach ensures compatibility with different Rails setups while maintaining a consistent API.

## The journey of an asset[](https://radanskoric.com/articles/rails-assets-propshaft-importmaps#the-journey-of-an-asset)

Step back and consider the journey of a javascript file. Much of the article applies to other assets, like stylesheets or images, but only in the Propshaft part. Importmaps are a uniquely javascript mechanism and we’re concentrating on the interplay of the two.

The javascript library initially starts in some registry on the internet. For example on npm or bundled with a gem. It finishes as part of a web application, being imported and executed. To get there it goes through following steps:

1.  **Download:** we have to download it and make it part of our application build.
2.  **Digest**: It needs to be digested and a fingerprint added to it. This is essential in making production caches work across application deploys.
3.  **Copy to public folder**: the digested file is moved to the public folder to be served by the web server.
4.  **Add to manifest**: the manifest<sup id="fnref:3"><a href="https://radanskoric.com/articles/rails-assets-propshaft-importmaps#fn:3" rel="footnote" role="doc-noteref">2</a></sup> file contains a mapping from the original file name, which we reference in our code, to the digested one.
5.  **Render importmap**: We have to render an importmap file which maps from names we’ll use in our `import` statements to the actual .
6.  **Preload**: typically we need also add preload `script` tags so browser knows to load them in advance.

Steps 1, 5 and 6 are handled by **importmap-rails** and steps 2, 3 and 4 are handled by **Propshaft**. This separation is important so here it is again, as a diagram:

```
flowchart LR
    subgraph "importmap-rails"
        A[download]
    end
    subgraph "propshaft"
        A --> C[digest]
        C --> D[add to manifest]
        C --> E[copy to public folder]
    end
    subgraph "importmap-rails"
      D --> F[render importmap]
      F --> G[preload]
    end
```

```
importmap-railspropshaftrender importmappreloaddigestadd to manifestcopy to public folderdownload
```

## The technical details[](https://radanskoric.com/articles/rails-assets-propshaft-importmaps#the-technical-details)

### Downloading[](https://radanskoric.com/articles/rails-assets-propshaft-importmaps#downloading)

There are two main ways by which javascript files get into your vanilla Rails 8 project:

1.  Using the `bin/importmap pin` command to add npm packages directly. It will download them into the `vendor/javascript` folder using [JSPM](https://jspm.org/) API to resolve the npm package name to the actual file. JSPM is a project that specifically provides management of npm packages for importmaps.
2.  By using a **Ruby gem** that has the assets included with its source. For example this is how [turbo-rails gem brings turbo](https://github.com/hotwired/turbo-rails/tree/main/app/assets/javascripts).

In the above diagram I assumed the first option.

The only requirement of this step is that the file ends up in one of the folders that are listed in the `config.assets.paths` setting of the application.

That is why importmap-rails [adds vendor/javascript](https://github.com/rails/importmap-rails/blob/d91d5e134d3f27e2332a8cb2ac015ea03d130621/lib/importmap/engine.rb#L47) to it and turbo-rails adds its own [app/assets/javascripts folder](https://github.com/hotwired/turbo-rails/tree/main/app/assets/javascripts).

> To bring assets into the Rails 8 asset pipeline in some other, custom way, you just need to ensure that the folder where they end up is listed in `Rails.configuration.assets.paths`. If that’s true then the rest of the pipeline will work just fine.
> 
> The download step is the easiest to customize.

### Processing the files[](https://radanskoric.com/articles/rails-assets-propshaft-importmaps#processing-the-files)

Here by processing I mean the following 3 steps: **digest**, **move to folder** and **add to manifest**. If you remember, they’re all done by **Propshaft**.

For every asset that’s found in the asset folder Propshaft will:

1.  Digest its content by running it through SHA1 hashing algorithm to get its **fingerprint**.
2.  Copy it to the public folder but append the fingerprint: `filename-fingerprint.js`.
3.  Add it to the manifest file. The manifest file has a mapping from the original to the digested name. Otherwise the rest of the code couldn’t find it. Manifest file is created when assets are compiled and loaded when the app boots. It is then used to resolve real asset files.

The only thing that the rest of the application needs from Propshaft is a way to get the public folder path from the original filename. Propshaft does that by implementing the `path_to_asset` helper<sup id="fnref:2"><a href="https://radanskoric.com/articles/rails-assets-propshaft-importmaps#fn:2" rel="footnote" role="doc-noteref">3</a></sup> which resolves the filename to the actual fingerprinted public folder path.

This is what Propshaft does out of the box. It doesn’t do anything else you might expect from an asset processor: like minification or tree-shaking. There is a way to get and that is covered in the [next article in the series](https://radanskoric.com/articles/rails-assets-deep-dive-propshaft). Subscribe to not miss it. As a bonus I’ll also send you a printableTurbo 8 cheatsheet:

### Building the importmap[](https://radanskoric.com/articles/rails-assets-propshaft-importmaps#building-the-importmap)

The last step is where importmap-rails comes in with its own core functionality: building the importmap and preloading javascript files.

It does that by evaluating `config/importmap.rb`. It is a Ruby file but it is not loaded directly. It’s loaded by importmap-rails gem and executed in a context where its DSL is implemented. This is done in the [Importmap::Map#draw method](https://github.com/rails/importmap-rails/blob/d91d5e134d3f27e2332a8cb2ac015ea03d130621/lib/importmap/map.rb#L16) by using `instance_eval` to evalute `importmap.rb` in the context of an instance of `Importmap::Map` object.

Let’s look at the following two entries you’ll find at the start of every new Rails 8 application:

`<table><tbody><tr><td><pre>1 2 </pre></td><td><pre><span>pin</span> <span>"application"</span> <span>pin</span> <span>"@hotwired/turbo-rails"</span><span>,</span> <span>to: </span><span>"turbo.min.js"</span> </pre></td></tr></tbody></table>`

Here’s what’s happening with them:

1.  `pin` methods adds an entry to the a internal object mapping the **import name** to the the **asset name**. If there’s a `to:` parameter, it uses that as the asset name, otherwise it just appends `.js` to the import name. I.e., turbo rails will be mapped to `turbo.min.js` and application to `application.js`.
2.  When it’s rendering the importmap it uses the `path_to_asset` helper to resolve that name to the actual file location. In this example it will call `path_to_asset("application.js")` and `path_to_asset("turbo.min.js")`. **This is the only touching point between importmap-rails and Propshaft.** It’s a really small surface are, they’re very orthogonal.
3.  Finally it renders the importmap and preload script tags. This is what the `javascript_importmap_tags` helper does.

For the `importmap.rb` example above, the final output would look something like this:

`<table><tbody><tr><td><pre>1 2 3 4 5 6 7 8 </pre></td><td><pre><span>&lt;script </span><span>type=</span><span>"importmap"</span> <span>data-turbo-track=</span><span>"reload"</span><span>&gt;</span><span>{</span>   <span>"</span><span>imports</span><span>"</span><span>:</span> <span>{</span>     <span>"</span><span>application</span><span>"</span><span>:</span> <span>"</span><span>/assets/application-f0907bdc.js</span><span>"</span><span>,</span>     <span>"</span><span>@hotwired/turbo-rails</span><span>"</span><span>:</span> <span>"</span><span>/assets/turbo.min-fae85750.js</span><span>"</span>   <span>}</span> <span>}</span><span>&lt;/script&gt;</span> <span>&lt;link</span> <span>rel=</span><span>"modulepreload"</span> <span>href=</span><span>"/assets/application-f0907bdc.js"</span><span>&gt;</span> <span>&lt;link</span> <span>rel=</span><span>"modulepreload"</span> <span>href=</span><span>"/assets/turbo.min-fae85750.js"</span><span>&gt;</span> </pre></td></tr></tbody></table>`

> The top level helper is just a convenience method calling lower level helpers. If you’re not happy with its output, you can drop down to the lower ones. See their [source code](https://github.com/rails/importmap-rails/blob/main/app/helpers/importmap/importmap_tags_helper.rb) to get the details.

With the above importmap, whenever we use a statement like `import "@hotwired/turbo-rails"` in a js file, the browser will:

1.  Look up `@hotwired/turbo-rails` in the importmap, see that it resolves to `/assets/turbo.min-fae85750.js`.
2.  Proceed to load `/assets/turbo.min-fae85750.js` from the server but notice it already has it preloaded.
3.  Import it and make available in the js file with the `import` statement.
    
    ## The summary[](https://radanskoric.com/articles/rails-assets-propshaft-importmaps#the-summary)
    

[Propshaft](https://github.com/rails/propshaft):

-   Does not download any files, it works with files you have on the disk.
-   Processes files, adds fingerprints, and moves them to the public folder (or serves dynamically in dev environment).
-   Does change the asset files.
-   Creates the manifest which is used to locate the asset.
-   It implements `path_to_asset` helper to resolve a file name to its actual fingerprinted location.
-   Takes care of actually serving the final asset file in development.

[importmap-rails](https://github.com/rails/importmap-rails):

-   Can be used to download the source files of npm packages. It’s not needed for that if the js files are coming bundled with a ruby gem.
-   Provides a mechanism to defined and render an `importmap`.
-   Uses the concept of pinning an import name to asset name which it then resolves to the actual source file location with `path_to_asset`. **This is the only touching point between the two gems.**
-   Does not do any changes to the asset files.

Now we know how the Rails 8 asset pipeline is integrated. In the [next article](https://radanskoric.com/articles/rails-assets-deep-dive-propshaft) I dive into how asset processing gets integrated with Propshaft. And after that one I [explore how to combine multiple importmaps](https://radanskoric.com/articles/rails-assets-combine-importmaps).