// Trumbowyg initialization for ActiveAdmin
// This file initializes Trumbowyg editors when the page loads

// Wait for DOM to be ready
function initTrumbowygEditors() {
  const editors = document.querySelectorAll('[data-aa-trumbowyg]');
  
  if (editors.length === 0) {
    console.log('No Trumbowyg editors found on page');
    return;
  }
  
  console.log(`Initializing ${editors.length} Trumbowyg editor(s)`);
  
  // Load jQuery and Trumbowyg from the bundle
  import('/assets/trumbowyg_bundle.js').then(() => {
    if (typeof window.jQuery !== 'undefined' && window.jQuery.fn.trumbowyg) {
      const $ = window.jQuery;
      
      $('[data-aa-trumbowyg]').each(function () {
        const $element = $(this);
        if (!$element.hasClass('trumbowyg-textarea--active')) {
          let options = {
            svgPath: '/assets/trumbowyg/icons.svg'
          };
          
          // Merge with data-options if present
          const dataOptions = $element.data('options');
          if (dataOptions) {
            options = $.extend({}, options, dataOptions);
          }
          
          $element.trumbowyg(options);
          $element.addClass('trumbowyg-textarea--active');
        }
      });
      
      console.log('Trumbowyg editors initialized');
    } else {
      console.error('jQuery or Trumbowyg not loaded');
    }
  }).catch((error) => {
    console.error('Failed to load Trumbowyg bundle:', error);
  });
}

// Initialize on various page load events
document.addEventListener('DOMContentLoaded', initTrumbowygEditors);
document.addEventListener('turbo:load', initTrumbowygEditors);
document.addEventListener('turbolinks:load', initTrumbowygEditors);

// Also listen for ActiveAdmin has_many events
document.addEventListener('has_many_add:after', function(event) {
  if (event.target.classList.contains('has_many_container')) {
    initTrumbowygEditors();
  }
});

export { initTrumbowygEditors };