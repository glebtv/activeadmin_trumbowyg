// Webpack/esbuild pack file - imports dependencies and init logic
// Dependencies must be installed via NPM: npm install jquery trumbowyg
import $ from 'jquery';
import 'trumbowyg';
import 'trumbowyg/dist/ui/trumbowyg.css';

// Ensure jQuery is globally available
window.$ = window.jQuery = $;

// Import the initialization logic
import './init';