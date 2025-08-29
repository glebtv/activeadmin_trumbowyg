## [](https://discuss.rubyonrails.org/t/guide-to-rails-7-and-the-asset-pipeline/80851#intro-1)Intro

Rails 7 brought with it an overhaul of the Asset Pipeline in the form of multiple new gems that either introduced a new way of handling assets (importmaps-rails), or broke down existing gems (propshaft, jsbundling-rails, cssbundling-rails) into smaller parts that make use of existing standalone tools and therefore support modern features that were previously unavailable.

## ActiveAdmin Trumbowyg Integration

**Important**: As of version 2.0, this gem **no longer supports Sprockets**. You must use a modern JavaScript bundler (esbuild, webpack, or similar) with Rails 7+.

### Installation with Modern Bundlers (esbuild/webpack)

1. Install the NPM package:
   ```bash
   npm install @rocket-sensei/activeadmin_trumbowyg
   ```

2. Import the package in your JavaScript entrypoint (e.g., `app/javascript/application.js`):
   ```javascript
   import '@rocket-sensei/activeadmin_trumbowyg'
   ```

3. The package automatically:
   - Registers the Trumbowyg editor with ActiveAdmin
   - Loads all required styles
   - Configures the editor for `ActiveAdmin.FormBuilder`

### JavaScript Module Structure

The NPM package exports JavaScript modules from the `active_admin/` namespace:
- `active_admin/trumbowyg.js` - Main editor initialization
- `active_admin/init.js` - ActiveAdmin integration setup

### Migration from Sprockets

If you're upgrading from an older version that used Sprockets:

1. Remove any Sprockets require directives:
   ```javascript
   // Remove these lines:
   //= require activeadmin/trumbowyg
   //= require activeadmin/init
   ```

2. Remove the gem's assets from your Sprockets manifest
3. Install via NPM and import as shown above
4. Ensure you're using jsbundling-rails, propshaft, or similar modern asset handling

While a few of these gems are still in pre-release status, their maintainers, contributors and early adopters have already deployed them to production. However, widespread adoption is currently being hampered by the lack of detailed documentation and some missing features that would allow them to support more use cases.

With the creation of the new Rails Discord channel for people interested in contributing to Rails, I think it’s a good time to coordinate with the community so we can pare down the rough edges. Therefore I’d like to start this thread so we can make a more visible demonstration that there are people working to improve things and provide central source of knowledge while all the related guides haven’t been updated.

**If you want the TL:DR version of this guide, check “What will Rails recommend going forward?” further down.**

**This is a work in progress**

## [](https://discuss.rubyonrails.org/t/guide-to-rails-7-and-the-asset-pipeline/80851#four-approaches-to-the-asset-pipeline-2)Four approaches to the Asset Pipeline

-   Sprockets: The original asset pipeline gem, built for the HTTP/1 era and low javascript frontends. It handled the bundling and digesting of javascript, css and image files, without relying on node packages.
    
-   Webpacker/Shakapacker: Shipped with Rails 5.2, as a wrapper around the complexity of Webpack/Node/Yarn, this gem could completely replace Sprockets or simply take over javascript transpiling and bundling. It provided Rails “out of the box” support for SPA frameworks like React.
    
-   Import Maps: Shipped with Rails 7.0, it replaces Sprockets as the default asset pipeline gem. Although it eliminates the need for node/yarn and other complex tooling, it requires the application using it to be deployed in an environment that supports HTTP/2, otherwise it causes severe performance problems.
    
-   Bundling gems: Shipped with Rails 7.0, the multiple bundling gems provide a more traditional, if more modern, approach to the asset pipeline than import maps does. They basically break down the “all in one” approach of Sprockets into multiple smaller, specialized pieces. The main gems are propshaft, jsbundling and cssbundling.
    

## [](https://discuss.rubyonrails.org/t/guide-to-rails-7-and-the-asset-pipeline/80851#explanations-and-recommendations-3)Explanations and recommendations

I’m writing this not as maintainer of any of these gems, but as a regular contributor and someone who has deployed most of them in the monolithic production app that my own company relies on. Corrections and suggestions are welcome.

### [](https://discuss.rubyonrails.org/t/guide-to-rails-7-and-the-asset-pipeline/80851#sprockets-4)Sprockets

-   Status: Maintained (but **NOT supported by activeadmin_trumbowyg**)
    
-   Notes: Several fixes and updates are only available in the edge version.
    

The original asset pipeline gem, Sprockets provides bundling and digesting for javascript, css and image files. Built before node was widely adopted, Sprocket's "everything included" approach worked well for many years. However, as frontend programming became more complex, it started to fall behind dedicated tools like webpack. It was the only officially supported gem up to Rails 5.2, when Webpacker was introduced, and remained the default until Rails 7, when it was replaced by Import Maps.

**Important for activeadmin_trumbowyg users**: This gem no longer supports Sprockets. You must use a modern JavaScript bundler with the NPM package `@rocket-sensei/activeadmin_trumbowyg`.

**If you are learning Rails**: Don't use it. Your time will be better spent learning one of the more modern approaches.

**If you are starting a new app**: Only if you absolutely do not want to deal with node/yarn and are not ready for import maps. Note that activeadmin_trumbowyg will not work with Sprockets.

**If you have an existing app with Sprockets**: You can continue using it for other assets, but you'll need to migrate to a modern bundler to use activeadmin_trumbowyg. Sprockets will receive maintenance updates at least until Propshaft reaches 1.0, and probably longer.

### [](https://discuss.rubyonrails.org/t/guide-to-rails-7-and-the-asset-pipeline/80851#webpacker-5)Webpacker

-   Status: Retired
    
-   Notes: All work done for the unreleased version 6 went to Shakapacker.
    

Rails has always had a complicated relationship with vanilla javascript, and to get around perceived limitations of the language, it adopted coffeescript as the default. Things changed with the arrival of ES6 and Babel for transpilation, but getting everything working so that you could use modern features of the language while remaining compatible with older browsers was difficult. Webpacker was created to solve that problem and for some time provided the bridge for developers interested in investing more heavily in the javascript ecosystem.

Five years later, all browsers oficially support ES6, so transpilation was no longer necessary and the extra complexity not worth for many developers. This lead to Webpacker being retired.

**If you are learning Rails**: Don’t use it. If your plan is to build your frontend entirely with Rails and Hotwired, then import maps is the preferred approach. However if your plan is to use a framework like React, then Shakapacker is the official sucessor and includes all the nice things that most javascript developers expect.

**If you are starting a new app**: Don’t use it. SPAs should go with Shakapacker, the official sucessor of Webpacker, which supports things like HMR. Hotwired/Tailwind based apps should go with importmaps-rails, or the bundling gems, which let you to choose your preferred bundling tool (esbuild, postcss, etc.).

**If you have an existing app with Webpacker**: Give some serious consideration to replacing it. If your app is a SPA, specially a React one, then Shakapacker is your friend, as it’s the official sucessor to Webpacker. If you are mostly using Hotwired and doing server side rendering, jsbundling-rails + webpack is an easy migration (and you can later migrate to the excellent esbuild).

### [](https://discuss.rubyonrails.org/t/guide-to-rails-7-and-the-asset-pipeline/80851#import-maps-6)Import maps

-   Status: Released, in active development
    
-   Notes: A shim is available to provide support for older browsers.
    

Rails 7 apps defaults to the importmaps-rails gem, which shares the same name as the import maps feature in browsers. This gem relies on the trifecta of HTTP2 (which eliminates the penalty of many small files), wide spread support for ES6 and the import map feature (which can the added to legacy browsers and Safari through a shim).

**If you are learning Rails**: This is the preferred approach, but only if you plan on building your frontends with Rails/Hotwired. If you want to use React/Vue/etc. then go with Shakapacker.

**If you are starting a new app**: Is it an SPA or your planned production environment only support HTTP1? This is not your friend, go with Shakapacker or the bundlings gems. However, if you are on the Hotwired team and have Cloudflare or Nginx in front of your Puma servers, then sure!

**If you have an existing app**: Stay where you are. This is a very different approach to handling javascript and css files and will require extensive work to migrate, specially if you have a lot of frontend code or rely on many node packages.

### [](https://discuss.rubyonrails.org/t/guide-to-rails-7-and-the-asset-pipeline/80851#propshaft-7)Propshaft

-   Status: Alpha, in active development
    
-   Notes: Already deployed to production in Basecamp (and by me, FWIW).
    

The sucessor to Sprockets, it has a much smaller scope than its predecessor: it’s only handles digesting, fixin references in css files so they use the digested filename, and moving everything to the public folder.

This means that any setup using propshaft will also be using one or more of the new bundlings gems, probably jsbundling-rails and cssbundling-rails.

**If you are learning Rails**: Don’t use it. It has no documentation, very few users and is still in alpha. You are already going to be spending a lot of effort learning other things, no need to make your life harder.

**If you are starting a new app**: Stick to import maps if you are going with Hotwired or shakapacker if you are going with React.

**If you have an existing app**: Maybe. It should be an easy migration for apps that are running Sprockets (CSS and digests) and Webpacker (javascript) and will also allow you to later webpack with the phenomenal esbuild. Just make sure you are comfortable running pre-release code with almost zero documentation in production. For what is worth, I’m using it in production and so is Basecamp.

### [](https://discuss.rubyonrails.org/t/guide-to-rails-7-and-the-asset-pipeline/80851#jsbundling-rails-8)jsbundling-rails

-   Status: Released, in active development
    
-   Notes: **Recommended for activeadmin_trumbowyg users**
    

Provides javascript bundling features that were previously handled by Sprockets and Webpacker. Supports webpack, esbuild and rollup.

**For activeadmin_trumbowyg users**: This is the recommended approach. Install the NPM package with `npm install @rocket-sensei/activeadmin_trumbowyg` and import it in your JavaScript entrypoint.

**If you are learning Rails**: This is a good choice if you need npm packages or complex JavaScript features.

**If you are starting a new app**: Excellent choice for apps that need npm packages, including activeadmin_trumbowyg.

**If you have an existing app**: Great migration path from Webpacker or Sprockets, especially for activeadmin_trumbowyg integration.

### [](https://discuss.rubyonrails.org/t/guide-to-rails-7-and-the-asset-pipeline/80851#cssbundling-rails-9)cssbundling-rails

-   Status: Released, in active development
    
-   Notes:
    

Provides css bundling features that were previously handled by Sprockets and Webpacker. Supports Tailwind, Bootstrap, Bulma, PostCSS and Dart Sass.

**If you are learning Rails**:

**If you are starting a new app**:

**If you have an existing app**:

### [](https://discuss.rubyonrails.org/t/guide-to-rails-7-and-the-asset-pipeline/80851#dartsass-rails-10)dartsass-rails

-   Status: Released, in active development
    
-   Notes:
    

Same as cssbundling-rails, but specific for dart. A wrapper around the platform specific versions of dart, instead of the yarn versions.

**If you are learning Rails**:

**If you are starting a new app**:

**If you have an existing app**:

### [](https://discuss.rubyonrails.org/t/guide-to-rails-7-and-the-asset-pipeline/80851#what-will-rails-recommend-going-forward-11)What will Rails recommend going forward?

The default (no node/yarn):

-   Rails 7: Import Maps + Sprockets
-   Rails 8: Import Maps + Propshaft

The alternative way (with node/yarn and your choice of bundler):

-   Rails 7: Bundling Gems\* + Sprockets
-   Rails 8: Bundling Gems\* + Propshaft

\* Bundling gems are `cssbundling-rails`, `jsbundling-rails`, etc.

### [](https://discuss.rubyonrails.org/t/guide-to-rails-7-and-the-asset-pipeline/80851#github-pages-12)Github Pages

-   [Sprockets](https://github.com/rails/sprockets)
    
-   [Propshaft](https://github.com/rails/propshaft/)
    
-   [Shakapacker](https://github.com/shakacode/shakapacker)
    
-   [importmap-rails](https://github.com/rails/importmap-rails)
    
-   [jsbundling-rails](https://github.com/rails/jsbundling-rails)
    
-   [cssbundling-rails](https://github.com/rails/cssbundling-rails)
    
-   [dartsass-rails](https://github.com/rails/dartsass-rails)
    
-   [tailwind-rails](https://github.com/rails/tailwindcss-rails)
    

### [](https://discuss.rubyonrails.org/t/guide-to-rails-7-and-the-asset-pipeline/80851#upgrade-guides-13)Upgrade Guides

-   [From Turbolinks to Turbo](https://github.com/hotwired/turbo-rails/blob/main/UPGRADING.md)
    
-   [From Sprockets/Wepacker to Propshaft](https://github.com/rails/propshaft/blob/main/UPGRADING.md)
    
-   [From Webpacker to Shakapacker](https://github.com/shakacode/shakapacker/blob/master/docs/v6_upgrade.md)
    

### [](https://discuss.rubyonrails.org/t/guide-to-rails-7-and-the-asset-pipeline/80851#relevant-information-14)Relevant Information

-   [Modern web apps without JavaScript bundling or transpiling](https://world.hey.com/dhh/modern-web-apps-without-javascript-bundling-or-transpiling-a20f2755)
    
-   [Introducing Propshaft](https://world.hey.com/dhh/introducing-propshaft-ee60f4f6)
    

### Complete ActiveAdmin Trumbowyg Setup Example

For a new Rails 7+ app with ActiveAdmin and Trumbowyg:

1. **Setup Rails with jsbundling and cssbundling:**
   ```bash
   rails new myapp -j esbuild -c bootstrap
   cd myapp
   ```

2. **Add ActiveAdmin and activeadmin_trumbowyg gems:**
   ```ruby
   # Gemfile
   gem 'activeadmin'
   gem 'activeadmin_trumbowyg'
   ```

3. **Install the NPM package:**
   ```bash
   npm install @rocket-sensei/activeadmin_trumbowyg
   ```

4. **Import in your JavaScript entrypoint:**
   ```javascript
   // app/javascript/application.js
   import '@rocket-sensei/activeadmin_trumbowyg'
   ```

5. **Use in your ActiveAdmin forms:**
   ```ruby
   # app/admin/posts.rb
   form do |f|
     f.inputs do
       f.input :title
       f.input :content, as: :trumbowyg
     end
     f.actions
   end
   ```

**Note**: The JavaScript modules are now under the `active_admin/` namespace, not `activeadmin/`. The NPM package handles all initialization automatically when imported.

### [](https://discuss.rubyonrails.org/t/guide-to-rails-7-and-the-asset-pipeline/80851#changelog-15)Changelog

-   2022-06-17: First version
-   2022-06-18: Added the 'Four approaches' section. Rewrote some explanations
-   2022-06-28: Added "What will Rails recommend".
-   2024-XX-XX: Added activeadmin_trumbowyg NPM package instructions and Sprockets deprecation notice