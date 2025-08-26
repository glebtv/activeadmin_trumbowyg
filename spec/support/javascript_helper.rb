# frozen_string_literal: true

module JavaScriptHelper
  def ensure_trumbowyg_loaded
    # Wait for jQuery to be available (loaded via asset pipeline)
    Timeout.timeout(5) do
      sleep 0.1 until page.evaluate_script('typeof jQuery !== "undefined" || typeof $ !== "undefined"')
    end

    # Wait for Trumbowyg to be available (loaded via asset pipeline)
    Timeout.timeout(5) do
      sleep 0.1 until page.evaluate_script('typeof jQuery !== "undefined" && typeof jQuery.trumbowyg !== "undefined"')
    end

    # Wait for at least one .trumbowyg-box to appear if there are inputs
    return unless page.has_css?('.trumbowyg-input', wait: 0)

    expect(page).to have_css('.trumbowyg-box', wait: 5)
  end
end

RSpec.configure do |config|
  config.include JavaScriptHelper, type: :system
end
