// Import ActiveAdmin - this already includes all features and Rails UJS
// DO NOT import Rails separately as it's already included and started in ActiveAdmin
import '@activeadmin/activeadmin';

// Import jQuery and Trumbowyg first (required by activeadmin_trumbowyg)
import $ from 'jquery';
import 'trumbowyg';

// Make jQuery globally available
window.$ = window.jQuery = $;

// Import ActiveAdmin Trumbowyg - single import loads everything
// NOTE: In production apps, users would need jQuery and Trumbowyg available
import 'activeadmin_trumbowyg';  // This is the exact import users should use