# Trumbowyg Editor for ActiveAdmin

An Active Admin plugin to use Trumbowyg Editor.

## v2.0.0 - TBD

### Breaking Changes
- **DROPPED SUPPORT** for ActiveAdmin < 4.0
- **DROPPED SUPPORT** for Ruby < 3.2
- **DROPPED SUPPORT** for Rails < 7.0
- Complete rewrite for ActiveAdmin 4.x compatibility

### New Features
- Added support for ActiveAdmin 4.x with modern JavaScript bundlers
- Added installation generator for esbuild, importmap, and webpack
- Created NPM package `@activeadmin/trumbowyg` for easier JavaScript management
- Added ESM modules for modern JavaScript bundlers
- Improved initialization with support for Turbo and dynamic content

### Migration Required
- Users of version 1.x should continue using that version for ActiveAdmin 1.x - 3.x
- See README for detailed migration instructions from version 1.x

### Technical Changes
- Updated CSS class from `data-aa-trumbowyg` to `trumbowyg-input`
- Moved from asset pipeline to modern JavaScript bundlers
- Added GitHub Actions CI workflow for Rails 7.x and 8.x
- Created vendor JavaScript file for importmap support

## v1.2.0 - 2025-04-13

- Update Trumbowyg to version 2.31.0
- Internal: improve tests
- Internal: update dev setup
- Internal: update CI configuration

## v1.1.0 - 2024-02-18

- Set minimum Ruby version to 3.0.0
- Set minimum ActiveAdmin version to 2.9.0
- Update CI configuration

## v1.0.0 - 2022-04-19

- Set minimum Ruby version to 2.6.0
- Remove `sassc` dependency
- Enable Ruby 3.0 specs support
- Enable Rails 7.0 specs support
- Internal improvements

## v0.2.16 - 2021-07-28

- Update Trumbowyg v2.25.1 (=> fix issue #17)

## v0.2.14 - 2021-07-15

- Update Trumbowyg to version 2.25.0
- Move some libs in the Gemfile
- Internal changes for the CI workflows using GitHub Actions

## v0.2.12 - 2021-04-09

- Update Trumbowyg to version 2.23.0

## v0.2.10 - 2021-03-19

- Fix editor loading with Turbolinks
- Specs improvements

## v0.2.8 - 2020-09-10

- CSS: reset only spacing for li elements in the editor
- JS: enable strict directive
- Minor specs improvement

## v0.2.6 - 2020-09-08

- JS refactoring
- README and examples improvements

## v0.2.4 - 2020-09-02

- Change styles file to SCSS + minor improvements
- Add specs for editor in nested resources
- Add Rubocop

## v0.2.0 - 2020-09-01

- Support ActiveAdmin 2.x
- Update Trumbowyg to version 2.21.0
- Add minimum specs (using RSpec)
