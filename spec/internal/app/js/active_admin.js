// Import ActiveAdmin - this already includes all features and Rails UJS
// DO NOT import Rails separately as it's already included and started in ActiveAdmin
import '@activeadmin/activeadmin';

// Import jQuery and make it globally available BEFORE loading Trumbowyg
import $ from 'jquery';
window.$ = window.jQuery = $;

// Now import Trumbowyg which depends on global jQuery
import 'trumbowyg';

// Import and setup ActiveAdmin Trumbowyg
import { setupAutoInit } from '@rocket-sensei/activeadmin_trumbowyg';

// Initialize the module after everything is loaded
setupAutoInit();