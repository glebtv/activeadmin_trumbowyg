// jQuery is injected globally via inject-jquery.js
import $ from 'jquery';
import 'trumbowyg';

// Import ActiveAdmin - this already includes all features and Rails UJS
// DO NOT import Rails separately as it's already included and started in ActiveAdmin
import '@activeadmin/activeadmin';

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