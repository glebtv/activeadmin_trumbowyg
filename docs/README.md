# ActiveAdmin 4 Migration Documentation

This directory contains essential documentation for migrating ActiveAdmin extension gems to support ActiveAdmin 4.

## Primary Guides

### 📘 [ActiveAdmin 4 Gem Migration Guide](activeadmin-4-gem-migration-guide.md)
**USE THIS FIRST** - Concise, step-by-step guide with the proven pattern for migrating gems.
- Quick checklist
- Critical configuration examples
- Common pitfalls and solutions
- ~10 minute read

### 📗 [Working Solution](WORKING_SOLUTION.md)
Complete working example from the activeadmin_trumbowyg gem migration.
- Full code examples
- Tested configuration
- Success indicators
- Use as reference implementation

### 📙 [Asset Pipeline v2 Notes](asset-failure-proceed-v2.md)
Critical findings about Tailwind safelist requirement.
- Why ActiveAdmin styling breaks without safelist
- Verification steps
- Common drift causes

## Reference Documentation

### [Detailed Reference](activeadmin-4-detailed-reference.md)
Comprehensive documentation with all migration details, testing patterns, and edge cases.

### [Rails 7 Asset Pipeline](rails-7-asset-pipeline.md)
Background on Rails 7 asset pipeline approaches (Sprockets, Import Maps, Bundling gems).

### [Combustion](combustion.md)
Testing ActiveAdmin gems with Combustion engine testing framework.

## Quick Start

For migrating a new gem, follow this order:
1. Read the **Migration Guide** for the pattern
2. Reference the **Working Solution** for code examples
3. Check **Asset Pipeline v2 Notes** for the safelist requirement
4. Use **Detailed Reference** for specific issues

## Key Insights

⚠️ **Critical Requirements**:
1. Tailwind safelist is MANDATORY - without it, ActiveAdmin layout completely breaks
2. Vendor CSS must be concatenated before Tailwind processing
3. jQuery injection pattern required for esbuild
4. Combustion loading order in config.ru is critical

## Success Metrics
- CSS file > 100KB (safelist + vendor CSS + ActiveAdmin)
- No console errors
- All UI elements properly styled
- Dark mode working
- Vendor components (editors, selects, etc.) fully functional