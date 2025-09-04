// ES Module version for ActiveAdmin 4+ with esbuild/webpack
// The consuming app must import jQuery and Trumbowyg BEFORE importing this module

// Constants
const PLUGIN_NAME = 'ActiveAdmin Trumbowyg';
const TRUMBOWYG_WRAPPER_CLASS = 'trumbowyg-wrapper';
const TRUMBOWYG_DARK_CLASS = 'trumbowyg-dark';
const TRUMBOWYG_ACTIVE_CLASS = 'trumbowyg-textarea--active';
const TRUMBOWYG_BOX_SELECTOR = '.trumbowyg-box';
const TRUMBOWYG_INPUT_SELECTOR = '[data-aa-trumbowyg], .trumbowyg-input';

// Helper function to get jQuery
function getJQuery() {
  return window.jQuery || window.$;
}

// Core initialization function
export function initTrumbowygEditors() {
  const $ = getJQuery();
  
  if (!$?.fn?.trumbowyg) {
    console.error(`${PLUGIN_NAME}: Trumbowyg plugin not found on jQuery`);
    return;
  }

  // Initialize both data-aa-trumbowyg and class-based selectors
  $(TRUMBOWYG_INPUT_SELECTOR).each(function () {
    const $this = $(this);
    
    // Skip if already initialized
    if ($this.hasClass(TRUMBOWYG_ACTIVE_CLASS)) {
      return;
    }

    // Default SVG path - can be overridden via data-options
    // In production with Propshaft, this will be served from /assets/
    // In development, you may need to copy to public/ or configure your asset pipeline
    let options = {
      svgPath: window.TRUMBOWYG_SVG_PATH || '/trumbowyg/icons.svg',
      autogrow: true,
      removeformatPasted: true
    };
    
    // Merge with data-options if present
    const dataOptions = $this.data('options');
    if (dataOptions) {
      options = $.extend({}, options, dataOptions);
    }
    
    // Only wrap if not already wrapped
    if (!$this.parent().hasClass(TRUMBOWYG_WRAPPER_CLASS)) {
      const $wrapper = $(`<div class="${TRUMBOWYG_WRAPPER_CLASS}"></div>`);
      if (isDarkMode()) {
        $wrapper.addClass(TRUMBOWYG_DARK_CLASS);
      }
      $this.wrap($wrapper);
    }
    
    // Initialize the editor
    $this.trumbowyg(options);
    $this.addClass(TRUMBOWYG_ACTIVE_CLASS);
    
    // Apply dark mode to the generated editor box
    if (isDarkMode()) {
      $this.closest(`.${TRUMBOWYG_WRAPPER_CLASS}`).find(TRUMBOWYG_BOX_SELECTOR).addClass(TRUMBOWYG_DARK_CLASS);
    }
  });
}

// Dark mode detection
function isDarkMode() {
  return document.documentElement.classList.contains('dark');
}

// Helper function to toggle dark class
function toggleDarkClass(element, isDark) {
  const $ = getJQuery();
  if (isDark) {
    $(element).addClass(TRUMBOWYG_DARK_CLASS);
  } else {
    $(element).removeClass(TRUMBOWYG_DARK_CLASS);
  }
}

// Update editors theme
export function updateEditorsTheme() {
  const $ = getJQuery();
  if (!$) return;
  
  const isDark = isDarkMode();
  
  // Update existing editors
  $(TRUMBOWYG_BOX_SELECTOR).each(function() {
    toggleDarkClass(this, isDark);
  });
  
  // Also update any wrappers we might have added
  $(`.${TRUMBOWYG_WRAPPER_CLASS}`).each(function() {
    toggleDarkClass(this, isDark);
  });
}

// Auto-initialize on common events
export function setupAutoInit() {
  const $ = getJQuery();
  if (!$) {
    console.error(`${PLUGIN_NAME}: jQuery not found for auto-init`);
    return;
  }

  // Initialize on DOM ready
  $(function() {
    initTrumbowygEditors();
    updateEditorsTheme();
  });

  // Support Turbo (Rails 7+)
  document.addEventListener('turbo:load', function() {
    initTrumbowygEditors();
    updateEditorsTheme();
  });

  // ActiveAdmin 4 uses .has-many-add button click
  $(document).on('click', '.has-many-add', function() {
    setTimeout(function() {
      initTrumbowygEditors();
      updateEditorsTheme();
    }, 10);
  });

  // Cleanup on Turbo before-cache
  $(document).on('turbo:before-cache', function() {
    $(`.${TRUMBOWYG_ACTIVE_CLASS}, .trumbowyg-input`).each(function() {
      const $this = $(this);
      if ($this.data('trumbowyg')) {
        $this.trumbowyg('destroy');
        $this.removeClass(TRUMBOWYG_ACTIVE_CLASS);
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
}