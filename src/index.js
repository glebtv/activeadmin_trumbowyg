// ES Module version for ActiveAdmin 4+ with esbuild/webpack
// Dependencies must be installed via NPM: npm install jquery trumbowyg
import $ from 'jquery';
import 'trumbowyg';
import 'trumbowyg/dist/ui/trumbowyg.css';

// Ensure jQuery is globally available (required by ActiveAdmin and Trumbowyg)
if (!window.$) {
  window.$ = $;
}
if (!window.jQuery) {
  window.jQuery = $;
}

// Core initialization function
function initTrumbowygEditors() {
  // Verify Trumbowyg is loaded
  if (!$.fn.trumbowyg) {
    console.error('ActiveAdmin Trumbowyg: Trumbowyg plugin not found on jQuery');
    return;
  }

  // Initialize both data-aa-trumbowyg and class-based selectors
  $('[data-aa-trumbowyg], .trumbowyg-input').each(function () {
    const $this = $(this);
    
    // Skip if already initialized
    if ($this.hasClass('trumbowyg-textarea--active')) {
      return;
    }

    let options = {
      svgPath: false, // Icons are embedded in the CSS from NPM package
      autogrow: true,
      removeformatPasted: true
    };
    
    // Merge with data-options if present
    const dataOptions = $this.data('options');
    if (dataOptions) {
      options = $.extend({}, options, dataOptions);
    }
    
    // Only wrap if not already wrapped
    if (!$this.parent().hasClass('trumbowyg-wrapper')) {
      const $wrapper = $('<div class="trumbowyg-wrapper"></div>');
      if (isDarkMode()) {
        $wrapper.addClass('trumbowyg-dark');
      }
      $this.wrap($wrapper);
    }
    
    // Initialize the editor
    $this.trumbowyg(options);
    $this.addClass('trumbowyg-textarea--active');
    
    // Apply dark mode to the generated editor box
    if (isDarkMode()) {
      $this.closest('.trumbowyg-wrapper').find('.trumbowyg-box').addClass('trumbowyg-dark');
    }
  });
}

// Dark mode detection
function isDarkMode() {
  return document.documentElement.classList.contains('dark');
}

// Update editors theme
function updateEditorsTheme() {
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

// Initialize on DOM ready
$(function() {
  initTrumbowygEditors();
  updateEditorsTheme();
});

// Support Turbo (Rails 7+) and Turbolinks (older Rails)
document.addEventListener('turbo:load', function() {
  initTrumbowygEditors();
  updateEditorsTheme();
});

document.addEventListener('turbolinks:load', function() {
  initTrumbowygEditors();
  updateEditorsTheme();
});

// Support ActiveAdmin has_many fields
$(document).on('has_many_add:after', '.has_many_container', function() {
  initTrumbowygEditors();
  updateEditorsTheme();
});

// Also listen for the has-many-add button click (ActiveAdmin 4)
$(document).on('click', '.has-many-add', function() {
  setTimeout(function() {
    initTrumbowygEditors();
    updateEditorsTheme();
  }, 10);
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

// Listen for theme changes
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

// Export for potential direct usage
export { initTrumbowygEditors, updateEditorsTheme };