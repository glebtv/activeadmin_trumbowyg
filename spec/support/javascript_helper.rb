# frozen_string_literal: true

module JavaScriptHelper
  def ensure_trumbowyg_loaded
    # Inject the compiled JavaScript bundle that includes jQuery and Trumbowyg
    inject_javascript_assets
    
    # Wait for jQuery to be available
    wait_for_jquery

    # Wait for Trumbowyg to be available 
    wait_for_trumbowyg

    # Initialize any existing Trumbowyg inputs
    initialize_trumbowyg_editors

    # Wait for at least one .trumbowyg-box to appear if there are inputs
    return unless page.has_css?('.trumbowyg-input', wait: 0)

    expect(page).to have_css('.trumbowyg-box', wait: 5)
  end

  private

  def inject_javascript_assets
    # Load jQuery first
    load_jquery
    wait_for_jquery
    
    # Load Trumbowyg
    load_trumbowyg
    wait_for_trumbowyg
    
    # Load ActiveAdmin Trumbowyg integration
    load_activeadmin_trumbowyg
  rescue StandardError => e
    raise "Failed to load JavaScript assets: #{e.message}"
  end
  
  def load_jquery
    return if page.evaluate_script('typeof jQuery !== "undefined"')
    
    # Load jQuery from CDN since it might conflict with Rails assets
    page.execute_script(<<~JS)
      if (typeof jQuery === 'undefined') {
        var script = document.createElement('script');
        script.src = 'https://code.jquery.com/jquery-3.7.1.min.js';
        script.onload = function() {
          window.$ = window.jQuery;
        };
        document.head.appendChild(script);
      }
    JS
  end
  
  def load_trumbowyg
    # Don't check if jQuery is loaded - that's handled by wait_for_jquery
    return if page.evaluate_script('typeof jQuery !== "undefined" && typeof jQuery.fn.trumbowyg !== "undefined"')
    
    # Load Trumbowyg CSS and JS from CDN
    page.execute_script(<<~JS)
      // Add Trumbowyg CSS
      var link = document.createElement('link');
      link.rel = 'stylesheet';
      link.href = 'https://cdn.jsdelivr.net/npm/trumbowyg@2/dist/ui/trumbowyg.min.css';
      document.head.appendChild(link);
      
      // Add Trumbowyg JS
      var script = document.createElement('script');
      script.src = 'https://cdn.jsdelivr.net/npm/trumbowyg@2/dist/trumbowyg.min.js';
      document.head.appendChild(script);
    JS
  end
  
  def load_activeadmin_trumbowyg
    # Load the ActiveAdmin Trumbowyg integration code inline
    page.execute_script(<<~JS)
      // ActiveAdmin Trumbowyg integration
      (function() {
        function initTrumbowygEditors() {
          $('.trumbowyg-input').each(function() {
            var $this = $(this);
            if ($this.data('trumbowyg-initialized')) return;
            
            var options = $this.data('options') || {};
            var defaultOptions = {
              svgPath: 'https://cdn.jsdelivr.net/npm/trumbowyg@2/dist/ui/icons.svg',
              autogrow: true,
              removeformatPasted: true
            };
            var finalOptions = $.extend({}, defaultOptions, options);
            
            $this.trumbowyg(finalOptions);
            $this.data('trumbowyg-initialized', true);
          });
        }
        
        // Make available globally
        if (typeof window !== 'undefined') {
          window.ActiveAdminTrumbowyg = {
            init: initTrumbowygEditors
          };
        }
        
        // Initialize on DOM ready and ActiveAdmin events
        $(document).ready(function() {
          initTrumbowygEditors();
          
          $(document).on('has_many_add:after', '.has_many_container', function() {
            initTrumbowygEditors();
          });
        });
      })();
    JS
  end

  def wait_for_jquery
    Timeout.timeout(10) do
      loop do
        jquery_available = page.evaluate_script('typeof jQuery !== "undefined" || typeof $ !== "undefined"')
        break if jquery_available

        sleep 0.05
      end
    end
  rescue Timeout::Error
    # Additional debugging for jQuery loading issues
    dom_ready = page.evaluate_script('document.readyState')
    scripts_count = page.evaluate_script('document.scripts.length')
    raise "jQuery not available after 10s. DOM state: #{dom_ready}, Scripts: #{scripts_count}"
  end

  def wait_for_trumbowyg
    Timeout.timeout(10) do
      loop do
        trumbowyg_available = page.evaluate_script(<<~JS)
          (function() {
            try {
              return typeof jQuery !== "undefined" && typeof jQuery.fn.trumbowyg !== "undefined";
            } catch(e) {
              return false;
            }
          })()
        JS
        break if trumbowyg_available

        sleep 0.05
      end
    end
  rescue Timeout::Error
    jquery_version = page.evaluate_script('typeof jQuery !== "undefined" ? jQuery.fn.jquery : "not loaded"')
    raise "Trumbowyg not available after 10s. jQuery version: #{jquery_version}"
  end

  def initialize_trumbowyg_editors
    # Initialize Trumbowyg on .trumbowyg-input elements
    page.execute_script(<<~JS)
      if (typeof jQuery !== 'undefined' && typeof jQuery.fn.trumbowyg !== 'undefined' && typeof window.ActiveAdminTrumbowyg !== 'undefined') {
        window.ActiveAdminTrumbowyg.init();
      }
    JS
  end
end

RSpec.configure do |config|
  config.include JavaScriptHelper, type: :system
end
