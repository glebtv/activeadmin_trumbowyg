# frozen_string_literal: true

module JavaScriptHelper
  def ensure_trumbowyg_loaded
    # Inject jQuery if not present
    page.execute_script(<<~JS)
      if (typeof jQuery === 'undefined' && typeof $ === 'undefined') {
        var script = document.createElement('script');
        script.src = 'https://code.jquery.com/jquery-3.7.1.min.js';
        document.head.appendChild(script);
      }
    JS

    # Wait for jQuery to load
    Timeout.timeout(5) do
      sleep 0.1 until page.evaluate_script('typeof jQuery !== "undefined" || typeof $ !== "undefined"')
    end

    # Make jQuery available as both jQuery and $
    page.execute_script('window.$ = window.jQuery = window.jQuery || window.$;')

    # Load Trumbowyg CSS and JS
    page.execute_script(<<~JS)
      if (typeof jQuery !== 'undefined' && typeof jQuery.trumbowyg === 'undefined') {
        // Add CSS
        var link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = 'https://cdn.jsdelivr.net/npm/trumbowyg@2/dist/ui/trumbowyg.min.css';
        document.head.appendChild(link);
      #{'  '}
        // Add JS
        var script = document.createElement('script');
        script.src = 'https://cdn.jsdelivr.net/npm/trumbowyg@2/dist/trumbowyg.min.js';
        script.onload = function() {
          // Initialize Trumbowyg on elements with the trumbowyg-input class
          function initTrumbowyg() {
            $('.trumbowyg-input').each(function() {
              var $this = $(this);
              if ($this.data('trumbowyg-initialized')) return;
      #{'        '}
              var options = $this.data('options') || {};
              var defaultOptions = {
                svgPath: 'https://cdn.jsdelivr.net/npm/trumbowyg@2/dist/ui/icons.svg',
                autogrow: true,
                removeformatPasted: true
              };
              var finalOptions = $.extend({}, defaultOptions, options);
      #{'        '}
              $this.trumbowyg(finalOptions);
              $this.data('trumbowyg-initialized', true);
            });
          }
      #{'    '}
          // Initialize immediately and on DOM changes
          initTrumbowyg();
          $(document).on('has_many_add:after', '.has_many_container', function() {
            initTrumbowyg();
          });
        };
        document.head.appendChild(script);
      }
    JS

    # Wait for Trumbowyg to load
    Timeout.timeout(5) do
      sleep 0.1 until page.evaluate_script('typeof jQuery !== "undefined" && typeof jQuery.trumbowyg !== "undefined"')
    end

    # Initialize any existing Trumbowyg inputs
    page.execute_script(<<~JS)
      $('.trumbowyg-input').each(function() {
        var $this = $(this);
        if (!$this.data('trumbowyg-initialized')) {
          var options = $this.data('options') || {};
          var defaultOptions = {
            svgPath: 'https://cdn.jsdelivr.net/npm/trumbowyg@2/dist/ui/icons.svg',
            autogrow: true,
            removeformatPasted: true
          };
          var finalOptions = $.extend({}, defaultOptions, options);
      #{'    '}
          $this.trumbowyg(finalOptions);
          $this.data('trumbowyg-initialized', true);
        }
      });
    JS

    # Wait for at least one .trumbowyg-box to appear if there are inputs
    return unless page.has_css?('.trumbowyg-input', wait: 0)

    expect(page).to have_css('.trumbowyg-box', wait: 5)
  end
end

RSpec.configure do |config|
  config.include JavaScriptHelper, type: :system
end
