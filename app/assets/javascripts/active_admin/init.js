// ActiveAdmin Trumbowyg - Core initialization logic
// This file uses IIFE pattern with no imports/exports for compatibility
(function() {
  'use strict';

  // Dark mode detection and management
  const THEME_KEY = "theme";

  // Check if dark mode is active
  function isDarkMode() {
    return document.documentElement.classList.contains('dark');
  }

  // Update Trumbowyg editors for dark mode
  function updateEditorsTheme() {
    const $ = window.jQuery || window.$;
    if (!$) return;
    
    const isDark = isDarkMode();
    
    // Update existing editors
    $('.trumbowyg-box').each(function() {
      if (isDark) {
        $(this).addClass('trumbowyg-dark');
      } else {
        $(this).removeClass('trumbowyg-dark');
      }
    });
    
    // Also update any wrappers we might have added
    $('.trumbowyg-wrapper').each(function() {
      if (isDark) {
        $(this).addClass('trumbowyg-dark');
      } else {
        $(this).removeClass('trumbowyg-dark');
      }
    });
  }

  // Function to initialize Trumbowyg editors
  function initTrumbowygEditors() {
    const $ = window.jQuery || window.$;
    
    if (!$) {
      console.error('ActiveAdmin Trumbowyg: jQuery is required but not found');
      return;
    }
    
    if (!$.fn.trumbowyg) {
      console.error('ActiveAdmin Trumbowyg: Trumbowyg library is required but not found');
      return;
    }
    
    // Initialize both data-aa-trumbowyg and class-based selectors
    $('[data-aa-trumbowyg], .trumbowyg-input').each(function () {
      if (!$(this).hasClass('trumbowyg-textarea--active')) {
        let options = {
          // Icons are embedded in the CSS from NPM package
          svgPath: false,
          autogrow: true,
          removeformatPasted: true
        };
        
        // Merge with data-options if present
        const dataOptions = $(this).data('options');
        if (dataOptions) {
          options = $.extend({}, options, dataOptions);
        }
        
        // Only wrap if not already wrapped
        if (!$(this).parent().hasClass('trumbowyg-wrapper')) {
          const $wrapper = $('<div class="trumbowyg-wrapper"></div>');
          if (isDarkMode()) {
            $wrapper.addClass('trumbowyg-dark');
          }
          $(this).wrap($wrapper);
        }
        
        // Initialize the editor
        $(this).trumbowyg(options);
        $(this).addClass('trumbowyg-textarea--active');
        
        // Apply dark mode to the generated editor box
        if (isDarkMode()) {
          $(this).closest('.trumbowyg-wrapper').find('.trumbowyg-box').addClass('trumbowyg-dark');
        }
      }
    });
  }

  // Set up event listeners
  function setupEventListeners() {
    const $ = window.jQuery || window.$;
    if (!$) return;
    
    // Listen for theme changes using MutationObserver
    const observer = new MutationObserver(function(mutations) {
      mutations.forEach(function(mutation) {
        if (mutation.type === 'attributes' && mutation.attributeName === 'class') {
          updateEditorsTheme();
        }
      });
    });

    // Start observing the html element for class changes
    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class']
    });

    // Listen for system preference changes
    const darkModeMedia = window.matchMedia('(prefers-color-scheme: dark)');
    darkModeMedia.addEventListener("change", updateEditorsTheme);

    // Listen for localStorage changes (when user switches theme in another tab)
    window.addEventListener("storage", function(event) {
      if (event.key === THEME_KEY) {
        updateEditorsTheme();
      }
    });

    // Initialize on various events
    $(document).ready(function() {
      initTrumbowygEditors();
      updateEditorsTheme();
    });

    // Listen for has_many add button clicks
    // ActiveAdmin 4 uses different events than ActiveAdmin 3
    $(document).on('click', '.has-many-add', function(event) {
      // Let ActiveAdmin's handler run first to insert the new fields
      setTimeout(function() {
        console.log('ActiveAdmin Trumbowyg: Initializing for newly added has_many fields');
        initTrumbowygEditors();
        updateEditorsTheme();
      }, 10);
    });
    
    // Also listen for the traditional has_many_add:after event (for compatibility)
    $(document).on('has_many_add:after', '.has_many_container', function() {
      console.log('ActiveAdmin Trumbowyg: Initializing for has_many fields (legacy event)');
      initTrumbowygEditors();
      updateEditorsTheme();
    });

    // Initialize on Turbo/Turbolinks navigation
    $(document).on('turbo:load turbolinks:load', function() {
      initTrumbowygEditors();
      updateEditorsTheme();
    });
    
    // Cleanup on Turbo before-cache
    $(document).on('turbo:before-cache', function() {
      $('.trumbowyg-textarea--active, .trumbowyg-input').each(function() {
        const $this = $(this);
        if ($this.data('trumbowyg')) {
          $this.trumbowyg('destroy');
          $this.removeClass('trumbowyg-textarea--active');
        }
      });
    });
  }

  // Initialize when DOM is ready
  if (typeof jQuery !== 'undefined') {
    jQuery(setupEventListeners);
  } else if (typeof $ !== 'undefined') {
    $(setupEventListeners);
  } else {
    // Wait for jQuery to be available
    document.addEventListener('DOMContentLoaded', function checkJQuery() {
      if (window.jQuery || window.$) {
        setupEventListeners();
      } else {
        console.warn('ActiveAdmin Trumbowyg: Waiting for jQuery...');
        setTimeout(checkJQuery, 100);
      }
    });
  }
  
  // Export functions for manual initialization if needed
  if (typeof window !== 'undefined') {
    window.ActiveAdminTrumbowyg = {
      init: initTrumbowygEditors,
      updateTheme: updateEditorsTheme
    };
  }
})();