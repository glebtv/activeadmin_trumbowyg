// ActiveAdmin Trumbowyg for importmap
// This file is for use with importmap-rails
(() => {
  'use strict';

  const waitForDependencies = (callback, retries = 50) => {
    if ((window.jQuery || window.$) && window.jQuery.trumbowyg) {
      callback();
    } else if (retries > 0) {
      setTimeout(() => waitForDependencies(callback, retries - 1), 100);
    } else {
      console.error('Trumbowyg dependencies not loaded. Please ensure jQuery and Trumbowyg are imported.');
    }
  };

  const initTrumbowyg = () => {
    const $ = window.jQuery || window.$;
    
    if (!$) {
      console.error('jQuery is required for Trumbowyg');
      return;
    }
    
    if (!$.trumbowyg) {
      console.warn('Trumbowyg is not loaded yet.');
      return;
    }

    $('[data-aa-trumbowyg], .trumbowyg-input').each(function() {
      const $this = $(this);
      
      if ($this.data('trumbowyg-initialized')) {
        return;
      }
      
      const options = $this.data('options') || {};
      
      // Default options
      const defaultOptions = {
        svgPath: false, // Icons are embedded in Trumbowyg CSS from CDN
        autogrow: true,
        removeformatPasted: true
      };
      
      // Merge options
      const finalOptions = Object.assign({}, defaultOptions, options);
      
      // Initialize Trumbowyg
      $this.trumbowyg(finalOptions);
      $this.data('trumbowyg-initialized', true);
    });
  };

  // Wait for dependencies and then initialize
  waitForDependencies(() => {
    const $ = window.jQuery || window.$;
    
    // Initialize on DOM ready
    $(() => {
      initTrumbowyg();
    });

    // Re-initialize on Turbo/Turbolinks load
    $(document).on('turbo:load turbolinks:load', () => {
      initTrumbowyg();
    });

    // Re-initialize for ActiveAdmin's has_many fields
    $(document).on('has_many_add:after', '.has_many_container', () => {
      initTrumbowyg();
    });

    // Cleanup on Turbo before-cache
    $(document).on('turbo:before-cache', () => {
      $('[data-aa-trumbowyg], .trumbowyg-input').each(function() {
        const $this = $(this);
        if ($this.data('trumbowyg')) {
          $this.trumbowyg('destroy');
          $this.data('trumbowyg-initialized', false);
        }
      });
    });
  });
})();