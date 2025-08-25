# frozen_string_literal: true

RSpec.describe 'Trumbowyg JS' do
  it 'defines a Javascript object for the editor', :aggregate_failures do
    visit '/admin/posts'
    
    # Wait for page to load and inject jQuery and Trumbowyg if needed
    page.execute_script(<<~JS)
      if (typeof jQuery === 'undefined') {
        var script = document.createElement('script');
        script.src = 'https://code.jquery.com/jquery-3.7.1.min.js';
        document.head.appendChild(script);
      }
    JS
    
    # Wait for jQuery to load
    Timeout.timeout(5) do
      sleep 0.1 until page.evaluate_script('typeof jQuery !== "undefined"')
    end
    
    # Load Trumbowyg
    page.execute_script(<<~JS)
      if (typeof jQuery !== 'undefined' && typeof jQuery.trumbowyg === 'undefined') {
        var link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = 'https://cdn.jsdelivr.net/npm/trumbowyg@2/dist/ui/trumbowyg.min.css';
        document.head.appendChild(link);
        
        var script = document.createElement('script');
        script.src = 'https://cdn.jsdelivr.net/npm/trumbowyg@2/dist/trumbowyg.min.js';
        document.head.appendChild(script);
      }
    JS
    
    # Wait for Trumbowyg to load
    Timeout.timeout(5) do
      sleep 0.1 until page.evaluate_script('typeof jQuery !== "undefined" && typeof jQuery.trumbowyg !== "undefined"')
    end

    expect(page.evaluate_script('typeof jQuery.trumbowyg')).to eq 'object'
  end
end