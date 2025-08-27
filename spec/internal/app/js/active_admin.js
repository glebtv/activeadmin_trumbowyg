// jQuery is injected globally via inject-jquery.js
import $ from 'jquery';
import 'trumbowyg';

// Import ActiveAdmin base (includes Rails UJS)
import '@activeadmin/activeadmin';

// Import ActiveAdmin features
import "@activeadmin/activeadmin/dist/active_admin/features/batch_actions";
import "@activeadmin/activeadmin/dist/active_admin/features/dark_mode_toggle";
import "@activeadmin/activeadmin/dist/active_admin/features/has_many";
import "@activeadmin/activeadmin/dist/active_admin/features/filters";
import "@activeadmin/activeadmin/dist/active_admin/features/main_menu";
import "@activeadmin/activeadmin/dist/active_admin/features/per_page";

// Ensure jQuery is available globally for other scripts
window.$ = window.jQuery = $;

// Function to initialize Trumbowyg editors
function initTrumbowygEditors() {
  $('[data-aa-trumbowyg]').each(function () {
    if (!$(this).hasClass('trumbowyg-textarea--active')) {
      let options = {
        // Use the asset path for SVG icons
        svgPath: '/assets/trumbowyg/icons.svg'
      };
      options = $.extend({}, options, $(this).data('options'));
      $(this).trumbowyg(options);
      $(this).addClass('trumbowyg-textarea--active');
    }
  });
}

// Initialize on various events
$(document).ready(initTrumbowygEditors);
$(document).on('has_many_add:after', '.has_many_container', initTrumbowygEditors);
$(document).on('turbo:load turbolinks:load', initTrumbowygEditors);

console.log('Trumbowyg initialized with esbuild');