# frozen_string_literal: true

RSpec.describe 'CSS Loading' do
  let!(:author) { Author.create!(email: 'test@example.com', name: 'Test Author') }
  let!(:post) { Post.create!(title: 'Test', author: author, description: '<p>Content</p>') }

  context 'when viewing the edit page', :js do
    before do
      visit edit_admin_post_path(post)
    end

    it 'loads Trumbowyg CSS from local assets' do # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
      # Check that Trumbowyg CSS is loaded from local assets, not CDN
      css_links = page.all('link[rel="stylesheet"]', visible: false).pluck('href')

      # Should have at least one CSS file from /assets/
      asset_css_links = css_links.select { |href| href&.include?('/assets/') }
      expect(asset_css_links).not_to be_empty, "No CSS files loaded from /assets/ - found: #{css_links.join(', ')}"

      # At least one should contain Trumbowyg styles
      # We check for this by looking for the actual CSS content
      trumbowyg_css_loaded = page.evaluate_script(<<~JS)
        (function() {
          // Check if any stylesheet contains Trumbowyg-specific classes
          var sheets = document.styleSheets;
          for (var i = 0; i < sheets.length; i++) {
            try {
              var rules = sheets[i].cssRules || sheets[i].rules;
              if (rules) {
                for (var j = 0; j < rules.length; j++) {
                  if (rules[j].selectorText && rules[j].selectorText.includes('.trumbowyg')) {
                    return true;
                  }
                }
              }
            } catch (e) {
              // Cross-origin stylesheets will throw an error
              // Check if this is a local asset stylesheet
              if (sheets[i].href && sheets[i].href.includes('/assets/')) {
                // For local stylesheets that we can't read, check if Trumbowyg styles are applied
                var testEl = document.createElement('div');
                testEl.className = 'trumbowyg-box';
                document.body.appendChild(testEl);
                var computed = window.getComputedStyle(testEl);
                var hasStyles = computed.position === 'relative' || computed.border !== '';
                document.body.removeChild(testEl);
                if (hasStyles) return true;
              }
            }
          }
          return false;
        })()
      JS

      expect(trumbowyg_css_loaded).to be_truthy, "Trumbowyg CSS styles not found in loaded stylesheets"
    end

    it 'loads ActiveAdmin CSS from local assets' do
      # Check that ActiveAdmin styles are present
      activeadmin_css_loaded = page.evaluate_script(<<~JS)
        (function() {
          // ActiveAdmin 4 uses different structure - check for the header bar
          var headerBar = document.querySelector('.border-b.border-gray-200');
          if (!headerBar) return false;
        #{'  '}
          var computed = window.getComputedStyle(headerBar);
          // Check that Tailwind styles are applied
          return computed.borderBottomWidth !== '0px' && computed.position === 'fixed';
        })()
      JS

      expect(activeadmin_css_loaded).to be_truthy, "ActiveAdmin CSS styles not properly loaded"
    end

    it 'does not load CSS from CDN' do
      # Ensure we're not loading from CDN
      css_links = page.all('link[rel="stylesheet"]', visible: false).pluck('href')
      cdn_links = css_links.select { |href| href&.match?(/cdn\.|jsdelivr|unpkg|cdnjs/) }

      expect(cdn_links).to be_empty, "CSS should not be loaded from CDN, but found: #{cdn_links.join(', ')}"
    end

    it 'has properly bundled CSS with all required styles' do # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
      # Check that the main CSS bundle includes both ActiveAdmin and Trumbowyg styles
      main_css_href = page.evaluate_script(<<~JS)
        Array.from(document.querySelectorAll('link[rel="stylesheet"]'))
          .map(link => link.href)
          .find(href => href.includes('/assets/active_admin'))
      JS

      expect(main_css_href).not_to be_nil, "No active_admin CSS bundle found"

      # Verify the bundled CSS contains expected content by checking applied styles
      bundle_contains_all = page.evaluate_script(<<~JS)
        (function() {
          // Check Trumbowyg styles on actual editor
          var trumbowygEditor = document.querySelector('.trumbowyg-editor');
          var hasTrambowygStyles = false;
          if (trumbowygEditor) {
            var trumbowygStyles = window.getComputedStyle(trumbowygEditor);
            hasTrambowygStyles = trumbowygStyles.minHeight !== '0px' && trumbowygStyles.minHeight !== '';
          }
        #{'  '}
          // Check ActiveAdmin 4 Tailwind styles
          var hasAdminStyles = false;
        #{'  '}
          // Check if Tailwind utilities are working on the header bar
          var headerBar = document.querySelector('.border-b.border-gray-200');
          if (headerBar) {
            var headerStyles = window.getComputedStyle(headerBar);
            // Check for Tailwind border and position styles
            hasAdminStyles = headerStyles.borderBottomWidth !== '0px' && headerStyles.position === 'fixed';
          }
        #{'  '}
          // Also check for proper page styling
          if (!hasAdminStyles) {
            var pageHeader = document.querySelector('[data-test-page-header]');
            if (pageHeader) {
              var pageStyles = window.getComputedStyle(pageHeader);
              hasAdminStyles = pageStyles.padding !== '0px';
            }
          }
        #{'  '}
          return {
            trumbowyg: hasTrambowygStyles,
            activeadmin: hasAdminStyles
          };
        })()
      JS

      expect(bundle_contains_all['trumbowyg']).to be_truthy, "CSS bundle missing Trumbowyg styles"
      expect(bundle_contains_all['activeadmin']).to be_truthy, "CSS bundle missing ActiveAdmin styles"
    end
  end
end
