# frozen_string_literal: true

RSpec.describe 'Trumbowyg JS' do
  it 'defines a Javascript object for the editor', :aggregate_failures do
    visit '/admin/posts'
    ensure_trumbowyg_loaded
    expect(page.evaluate_script('typeof jQuery.trumbowyg')).to eq 'object'
  end
end
