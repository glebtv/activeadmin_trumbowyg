import $ from 'jquery';

// Import Trumbowyg - we'll use CDN version for simplicity
// Users can override this with npm package if needed

// Ensure jQuery is globally available for ActiveAdmin and Trumbowyg
window.$ = window.jQuery = $;

// Import the initialization logic
import './trumbowyg_input_esm';