// https://github.com/evanw/esbuild/issues/1681
// This file injects jQuery as a global for all modules
export { default as $ } from 'jquery/dist/jquery.js'
export { default as jQuery } from 'jquery/dist/jquery.js'