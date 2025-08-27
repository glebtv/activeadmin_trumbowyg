// jQuery is injected globally via inject-jquery.js
import $ from 'jquery';
import 'trumbowyg';

// Import ActiveAdmin - this already includes all features and Rails UJS
// DO NOT import Rails separately as it's already included and started in ActiveAdmin
import '@activeadmin/activeadmin';

// Ensure jQuery is available globally for other scripts
window.$ = window.jQuery = $;

// Dark mode detection and management
const THEME_KEY = "theme";
const darkModeMedia = window.matchMedia('(prefers-color-scheme: dark)');

// Check if dark mode is active
function isDarkMode() {
  return document.documentElement.classList.contains('dark');
}

// Update Trumbowyg editors for dark mode
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

// Function to initialize Trumbowyg editors
function initTrumbowygEditors() {
  $('[data-aa-trumbowyg]').each(function () {
    if (!$(this).hasClass('trumbowyg-textarea--active')) {
      let options = {
        // Use the asset path for SVG icons
        svgPath: '/assets/trumbowyg/icons.svg'
      };
      options = $.extend({}, options, $(this).data('options'));
      
      // Wrap the editor in a div for dark mode if needed
      const $wrapper = $('<div class="trumbowyg-wrapper"></div>');
      if (isDarkMode()) {
        $wrapper.addClass('trumbowyg-dark');
      }
      $(this).wrap($wrapper);
      
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
darkModeMedia.addEventListener("change", updateEditorsTheme);

// Listen for localStorage changes (when user switches theme in another tab)
window.addEventListener("storage", (event) => {
  if (event.key === THEME_KEY) {
    updateEditorsTheme();
  }
});

// Initialize on various events
$(document).ready(function() {
  initTrumbowygEditors();
  updateEditorsTheme();
});

$(document).on('has_many_add:after', '.has_many_container', function() {
  initTrumbowygEditors();
  updateEditorsTheme();
});

$(document).on('turbo:load turbolinks:load', function() {
  initTrumbowygEditors();
  updateEditorsTheme();
});

console.log('Trumbowyg initialized with esbuild');