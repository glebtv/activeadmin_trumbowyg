#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const root = __dirname;
const inputPath = path.join(root, 'app/css/active_admin_source.css');
const vendorCssPath = path.join(root, 'node_modules/trumbowyg/dist/ui/trumbowyg.css');
const tmpPath = path.join(root, 'app/css/__aa_tmp.css');
const outPath = path.join(root, 'app/assets/builds/active_admin.css');

function build() {
  // Read source file or create default
  let srcContent = '';
  if (fs.existsSync(inputPath)) {
    srcContent = fs.readFileSync(inputPath, 'utf8');
  } else {
    // Create default source if it doesn't exist
    srcContent = `@tailwind base;
@tailwind components;
@tailwind utilities;

/* Custom Trumbowyg overrides */
.trumbowyg-box {
  @apply border border-gray-300 rounded-md;
}

.trumbowyg-editor {
  @apply min-h-[200px] p-3;
}

/* Dark mode support */
.dark .trumbowyg-box {
  @apply border-gray-600;
}

.dark .trumbowyg-button-pane {
  @apply bg-gray-800 border-gray-600;
}

.dark .trumbowyg-editor {
  @apply bg-gray-900 text-gray-100;
}

/* Fix button styles */
.trumbowyg-button-pane button {
  @apply hover:bg-gray-100 dark:hover:bg-gray-700;
}

/* Ensure icons are visible */
.trumbowyg-button-pane button svg {
  fill: currentColor !important;
}`;
  }

  // Extract tailwind directives and body content
  const lines = srcContent.split(/\r?\n/);
  const tailwindLines = lines.filter(line => line.includes('@tailwind'));
  const bodyLines = lines.filter(line => 
    !line.includes('@tailwind') && 
    !line.includes('trumbowyg/dist/ui/trumbowyg.css')
  );

  const tailwindDirectives = tailwindLines.join('\n') || '@tailwind base;\n@tailwind components;\n@tailwind utilities;';

  // Read Trumbowyg vendor CSS
  let vendorCss = '';
  
  if (fs.existsSync(vendorCssPath)) {
    vendorCss += `\n/* Begin Trumbowyg vendor CSS */\n`;
    vendorCss += fs.readFileSync(vendorCssPath, 'utf8');
    vendorCss += `\n/* End Trumbowyg vendor CSS */\n`;
  } else {
    console.warn('Warning: Trumbowyg CSS not found at', vendorCssPath);
  }

  const body = bodyLines.join('\n');

  // Combine all CSS - Tailwind directives, vendor CSS, then custom styles
  const tmpCss = `${tailwindDirectives}\n${vendorCss}\n${body}`;
  
  // Create directories if they don't exist
  const cssDir = path.dirname(tmpPath);
  if (!fs.existsSync(cssDir)) {
    fs.mkdirSync(cssDir, { recursive: true });
  }
  
  const buildDir = path.dirname(outPath);
  if (!fs.existsSync(buildDir)) {
    fs.mkdirSync(buildDir, { recursive: true });
  }
  
  fs.writeFileSync(tmpPath, tmpCss, 'utf8');

  // Run tailwindcss build
  const res = spawnSync('npx', [
    'tailwindcss',
    '-c', path.join(root, 'tailwind-active_admin.config.js'),
    '-i', tmpPath,
    '-o', outPath,
    '--minify'
  ], { stdio: 'inherit', cwd: root });

  if (res.status !== 0) {
    console.error('Tailwind build failed');
    process.exit(res.status || 1);
  }

  // Clean up temp file
  fs.unlinkSync(tmpPath);
  
  console.log(`ActiveAdmin CSS built successfully: ${outPath}`);
  const stats = fs.statSync(outPath);
  console.log(`File size: ${(stats.size / 1024).toFixed(2)} KB`);
}

build();