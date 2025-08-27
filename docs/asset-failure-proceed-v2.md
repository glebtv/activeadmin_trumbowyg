# ActiveAdmin 4 Asset Pipeline – Follow‑up Notes (v2)

These are additional findings and fixes beyond the original instructions in `docs/asset-failure-proceed.md`.

## Build/Config
- Tailwind config as ESM: use `spec/internal/tailwind.config.mjs` with `import activeAdminPlugin from '@activeadmin/activeadmin/plugin'` and `plugins: [activeAdminPlugin]`. Remove duplicate `tailwind.config.js` files.
- CSS build script: `spec/internal/build_css.js` concatenates Tailwind directives + Trumbowyg CSS (from npm) + our overrides, then calls Tailwind CLI with `-c tailwind.config.mjs`. `package.json` uses: `"build:css": "node ./build_css.js"`.
- Manifest serving: keep `//= link_tree ../builds` and do not link the empty `app/assets/stylesheets/active_admin.css` directly. Add `//= link trumbowyg/icons.svg` so toolbar icons resolve.

## Critical Fix: Tailwind Safelist
The ActiveAdmin gem path scanning wasn't sufficient. You MUST add a safelist to `tailwind.config.mjs`:

```javascript
export default {
  // ... existing content config ...
  plugins: [activeAdminPlugin],
  safelist: [
    // Grid and layout
    'grid', 'gap-4', 'gap-6', 'lg:grid-cols-3', 'md:grid-cols-2', 
    'col-span-2', 'col-span-3', 'lg:col-span-2', 'lg:col-span-1',
    // Flexbox
    'flex', 'flex-col', 'flex-row', 'flex-wrap', 'items-center', 'justify-between',
    // Spacing
    'p-4', 'p-6', 'px-4', 'px-6', 'py-2', 'py-4', 'm-0', 'mx-auto', 'mt-4', 'mb-4',
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
    'z-10', 'z-20', 'z-30', 'z-40', 'z-50',
    // Add more as needed
  ]
}
```

## Verification Steps
- Expected size: `app/assets/builds/active_admin.css` should be > 100KB with safelist, Tailwind + AA plugin + Trumbowyg.
- Expected markers in built CSS:
  - Tailwind header: `! tailwindcss v3.` and reset rules.
  - AA plugin: selectors like `[type='text']` and `.filters-form`.
  - Utility classes: `.grid`, `.flex`, `.gap-4`, etc.
  - Trumbowyg classes: ~180+ occurrences
- Curl the served asset to confirm server uses the new build:
  - `curl -s http://localhost:9292/assets/active_admin.css | head -50`
  - or the digest URL from the page's `<link rel="stylesheet">`.
- If the served file differs from `app/assets/builds/active_admin.css`, restart server and clear caches: remove `spec/internal/tmp/cache`, hard-reload browser.

## Common Drift Causes
- Multiple Tailwind configs in the tree (ESM vs CJS) — CLI may pick the wrong one. Keep only `tailwind.config.mjs`.
- Old build still linked: `manifest.js` linking the empty `active_admin.css` file instead of `../builds`.
- Browser serving stale digest: hard-reload or fetch via curl to verify.
- Missing safelist: Without the safelist, ActiveAdmin layout breaks even if gem paths are scanned.

## Icons Delivery
- Current: symlink `spec/internal/app/assets/trumbowyg/icons.svg` -> `node_modules/trumbowyg/dist/ui/icons.svg` and link it in `manifest.js`.
- Alternative (no symlink): add to assets paths and precompile in `spec/internal/config/initializers/assets.rb`:
  - `Rails.application.config.assets.paths << Rails.root.join('node_modules')`
  - `Rails.application.config.assets.precompile += %w[ trumbowyg/dist/ui/icons.svg ]`

## Optional Improvements
- PostCSS import: if you prefer `@import` from node_modules without a custom build script, add `postcss-import` and a `postcss.config.js` so Tailwind can inline vendor CSS.
- Rake task for CI: create a small Rake task or script that runs `npm run build` before starting the rack server for repeatability.

## Quick Sanity Checklist
- `npm run build:css` runs without errors; output contains Tailwind + AA selectors.
- `manifest.js` only exposes builds + icons (no direct link to empty stylesheet).
- One Tailwind config file: `tailwind.config.mjs` present; no `tailwind.config.js`.
- Icons available at `/assets/trumbowyg/icons.svg`.

