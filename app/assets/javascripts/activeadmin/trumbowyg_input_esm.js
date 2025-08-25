// Trumbowyg editor initialization for ActiveAdmin 4
(() => {
  'use strict';

  const initTrumbowyg = () => {
    const $ = window.jQuery || window.$;
    
    if (!$) {
      console.error('jQuery is required for Trumbowyg');
      return;
    }
    
    if (!$.trumbowyg) {
      console.warn('Trumbowyg is not loaded yet. Make sure to include it via CDN or npm.');
      return;
    }

    $('.trumbowyg-input').each(function() {
      const $this = $(this);
      
      if ($this.data('trumbowyg-initialized')) {
        return;
      }
      
      const options = $this.data('options') || {};
      
      // Default options
      const defaultOptions = {
        svgPath: '/assets/trumbowyg/icons.svg',
        autogrow: true,
        removeformatPasted: true
      };
      
      // Merge options
      const finalOptions = $.extend({}, defaultOptions, options);
      
      // Initialize Trumbowyg
      $this.trumbowyg(finalOptions);
      $this.data('trumbowyg-initialized', true);
    });
  };

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
    $('.trumbowyg-input').each(function() {
      const $this = $(this);
      if ($this.data('trumbowyg')) {
        $this.trumbowyg('destroy');
        $this.data('trumbowyg-initialized', false);
      }
    });
  });
})();