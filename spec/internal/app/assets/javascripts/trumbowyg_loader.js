//= require ./trumbowyg_bundle

// Initialize Trumbowyg editors after bundle loads
(function() {
  function waitForJQuery(callback) {
    if (typeof window.jQuery !== 'undefined' && window.jQuery.fn && window.jQuery.fn.trumbowyg) {
      callback(window.jQuery);
    } else {
      setTimeout(function() { waitForJQuery(callback); }, 50);
    }
  }
  
  function initEditors($) {
    $('[data-aa-trumbowyg]').each(function () {
      var $element = $(this);
      if (!$element.hasClass('trumbowyg-textarea--active')) {
        var options = {
          svgPath: '/assets/trumbowyg/icons.svg'
        };
        
        var dataOptions = $element.data('options');
        if (dataOptions) {
          options = $.extend({}, options, dataOptions);
        }
        
        $element.trumbowyg(options);
        $element.addClass('trumbowyg-textarea--active');
        console.log('Trumbowyg editor initialized');
      }
    });
  }
  
  document.addEventListener('DOMContentLoaded', function() {
    waitForJQuery(function($) {
      // Initialize on page load
      initEditors($);
      
      // Initialize on ActiveAdmin has_many events
      $(document).on('has_many_add:after', '.has_many_container', function() {
        initEditors($);
      });
      
      // Initialize on Turbo/Turbolinks events
      $(document).on('turbo:load turbolinks:load', function() {
        initEditors($);
      });
    });
  });
})();