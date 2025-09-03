# frozen_string_literal: true

RSpec.describe 'Trumbowyg JS', :js do
  it 'defines a Javascript object for the editor' do
    visit '/admin/posts'
    ensure_trumbowyg_loaded
    expect(page.evaluate_script('typeof jQuery.trumbowyg')).to eq 'object'
  end

  # rubocop:todo RSpec/ExampleLength, RSpec/MultipleExpectations
  # TODO: Refactor this test to reduce complexity and split into smaller examples
  it 'allows entering text with bold and italics formatting' do
    # Create an author first so we can select it
    author = Author.create!(name: 'Test Author', email: 'test@example.com')

    visit '/admin/posts/new'
    ensure_trumbowyg_loaded

    # Fill in the title field
    fill_in 'Title', with: 'Test Post with Formatting'

    # Select the author
    select author.name, from: 'Author'

    # Find the Trumbowyg editor for description field
    editor = find('#post_description_input .trumbowyg-editor')

    # Click into the editor to focus it
    editor.click

    # Type some regular text
    editor.send_keys('This is normal text. ')

    # Click the bold button (be specific about which editor's button)
    find('#post_description_input .trumbowyg-strong-button').click
    editor.send_keys('This is bold text. ')

    # Click bold again to turn it off, then click italic
    find('#post_description_input .trumbowyg-strong-button').click
    find('#post_description_input .trumbowyg-em-button').click
    editor.send_keys('This is italic text.')

    # Submit the form
    click_on 'Create Post'

    # Verify the post was created
    expect(page).to have_content('Post was successfully created')

    # Check that the formatted content was saved to the database
    post = Post.last
    expect(post.title).to eq('Test Post with Formatting')
    expect(post.description).to include('This is normal text')
    expect(post.description).to include('<strong>This is bold text.') # Bold text in HTML
    expect(post.description).to include('<em>This is italic text.</em>') # Italic text in HTML

    # Verify it displays correctly on the show page
    expect(page).to have_css('strong', text: 'This is bold text.')
    expect(page).to have_css('em', text: 'This is italic text.')
  end
  # rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations

  # rubocop:todo RSpec/ExampleLength, RSpec/MultipleExpectations
  # TODO: Refactor this test to reduce complexity and split into smaller examples
  it 'preserves formatting when editing an existing post' do
    # Create an author first
    author = Author.create!(name: 'Test Author', email: 'test@example.com')

    # Create a post with formatted content
    post = Post.create!(
      title: 'Existing Post',
      description: '<p>Normal text. <strong>Bold text.</strong> <em>Italic text.</em></p>',
      body: '<p>Test body</p>',
      author: author
    )

    visit "/admin/posts/#{post.id}/edit"
    ensure_trumbowyg_loaded

    # Verify the editor loaded with the formatted content
    editor = find('#post_description_input .trumbowyg-editor')
    expect(editor).to have_content('Normal text. Bold text. Italic text.')

    # Check that bold and italic formatting is visible in the editor
    within('#post_description_input .trumbowyg-editor') do
      expect(page).to have_css('strong', text: 'Bold text.')
      expect(page).to have_css('em', text: 'Italic text.')
    end

    # Add more content
    editor.click
    editor.send_keys(' Additional content.')

    # Update the post
    click_on 'Update Post'

    # Verify the update was successful
    expect(page).to have_content('Post was successfully updated')

    # Check the database has all content
    post.reload
    expect(post.description).to include('Normal text')
    expect(post.description).to include('<strong>Bold text.</strong>')
    expect(post.description).to include('<em>')
    expect(post.description).to include('Italic text.')
    expect(post.description).to include('Additional content.')
  end
  # rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
end
