# ActiveAdmin 4.0.0 Migration Guide: Breaking Changes and Asset Pipeline Updates

## Overview

ActiveAdmin 4.0.0 introduces significant changes to asset handling, dependencies, and configuration. This document outlines the key modifications developers need to be aware of when upgrading.

## 1. Asset Pipeline Changes

### Major Asset Handling Shifts
- Assumes `cssbundling-rails` and `importmap-rails` are installed
- Requires running `rails generate active_admin:assets` to replace old assets
- Moves away from legacy asset registration methods

### Asset Generation Steps
1. Install `cssbundling-rails` and `importmap-rails`
2. Run `rails generate active_admin:assets`
3. Manually configure asset generation scripts

## 2. JavaScript/CSS Handling

### Removed Configuration Options
The following configuration methods have been deprecated:
- `site_title_link`
- `site_title_image`
- `logout_link_method`
- `favicon`
- `meta_tags`
- `meta_tags_for_logged_out_pages`
- `register_stylesheet`
- `register_javascript`
- `head`
- `footer`
- `use_webpacker`

### Recommendation
Replace these configurations using partials and modern Rails asset pipeline techniques.

## 3. Tailwind CSS Integration

### Key Changes
- Native Tailwind CSS support
- Requires npm package installation
- Custom build scripts for CSS generation
- Flowbite dependency upgraded to v3.1.2

### Setup Requirements
- Install Tailwind CSS
- Configure build scripts
- Update component styling to use Tailwind classes

## 4. Breaking Changes from Version 3 to 4

### Ruby Support
- Dropped support for Ruby 3.0 and 3.1
- Minimum Ruby version: 3.2 (recommended)

### Rails Support
- Dropped support for Rails 6.1
- Minimum Rails version: 7.0 (recommended)

### Component Removals
- Removed Tabs component
- Removed `frozen_string_literal` comment from `.arb` templates
- Columns component replaced with div and Tailwind classes

## 5. New Dependency Requirements

### Gem Dependencies
- Formtastic bumped to version 5.0
- `inherited_resources` updated to `~> 2.0`

### JavaScript/NPM Dependencies
- Flowbite v3.1.2
- Tailwind CSS
- ESM (ECMAScript Module) support

## Migration Recommendations

1. Update Ruby and Rails to supported versions
2. Install `cssbundling-rails` and `importmap-rails`
3. Run `rails generate active_admin:assets`
4. Update Tailwind CSS configuration
5. Migrate custom styling to use Tailwind classes
6. Review and update any removed configuration methods

## Community Solutions

For those seeking a simpler migration path, consider the `activeadmin_assets` gem, which provides static asset copies and automatic injection.

## Conclusion

ActiveAdmin 4.0.0 represents a significant modernization of the framework, embracing contemporary asset management and styling approaches. Careful planning and incremental migration are recommended.