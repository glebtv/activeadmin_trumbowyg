#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const root = __dirname;
const inputPath = path.join(root, 'app/assets/stylesheets/active_admin_source.css');
const vendorCssPath = path.join(root, 'node_modules/trumbowyg/dist/ui/trumbowyg.css');
const tmpPath = path.join(root, 'app/assets/stylesheets/__aa_tmp.css');
const outPath = path.join(root, 'app/assets/builds/active_admin.css');

function build() {
  const src = fs.readFileSync(inputPath, 'utf8').split(/\r?\n/);
  const vendorCss = fs.readFileSync(vendorCssPath, 'utf8');

  // Remove any line that imports trumbowyg.css and capture the rest after the first 3 lines
  const tailwindDirectives = [
    '@tailwind base;',
    '@tailwind components;',
    '@tailwind utilities;'
  ].join('\n');

  const bodyLines = src.slice(3).filter(line => !line.includes('trumbowyg.css'));
  const body = bodyLines.join('\n');

  const tmpCss = `${tailwindDirectives}\n\n/* Begin Trumbowyg vendor CSS */\n${vendorCss}\n/* End Trumbowyg vendor CSS */\n\n${body}\n`;
  fs.writeFileSync(tmpPath, tmpCss, 'utf8');

  // Run tailwindcss build
  const res = spawnSync('npx', [
    'tailwindcss',
    '-c', path.join(root, 'tailwind.config.mjs'),
    '-i', tmpPath,
    '-o', outPath
  ], { stdio: 'inherit', cwd: root });

  if (res.status !== 0) {
    process.exit(res.status);
  }

  fs.unlinkSync(tmpPath);
}

build();
