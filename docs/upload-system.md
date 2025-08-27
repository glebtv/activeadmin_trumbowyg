# CKEditor5-Rails Upload System Documentation

## Overview

The CKEditor5-Rails gem implements a flexible image upload system that allows users to upload images directly from the editor to a server endpoint instead of embedding them as Base64. The system is designed to be backend-agnostic and can integrate with various storage solutions including ActiveStorage and Shrine.

## Architecture

### Core Components

#### 1. SimpleUploadAdapter Plugin (`lib/ckeditor5/rails/plugins/simple_upload_adapter.rb`)

The heart of the upload system is an inline JavaScript plugin that:
- Extends CKEditor5's Plugin class
- Requires the FileRepository plugin as a dependency
- Implements the upload adapter factory pattern
- Handles file uploads via XMLHttpRequest with progress tracking

**Location**: `lib/ckeditor5/rails/plugins/simple_upload_adapter.rb`

**Key Features**:
- Async/await based upload handling
- Progress tracking through XMLHttpRequest events
- CSRF token integration for Rails security
- Abort capability for cancelled uploads
- JSON response parsing for uploaded file URLs

#### 2. PropsInlinePlugin Base Class (`lib/ckeditor5/rails/editor/props_inline_plugin.rb`)

The upload adapter extends this base class which:
- Wraps JavaScript code in an async IIFE (Immediately Invoked Function Expression)
- Supports optional code compression via Terser
- Provides window-based plugin registration mechanism
- Handles plugin initialization errors gracefully

**Location**: `lib/ckeditor5/rails/editor/props_inline_plugin.rb`

#### 3. Plugin Registration System (`lib/ckeditor5/rails/plugins.rb`)

Central registry that:
- Loads all core plugins including SimpleUploadAdapter
- Manages plugin dependencies
- Handles plugin patches and fixes

**Location**: `lib/ckeditor5/rails/plugins.rb`

## Configuration System

### Preset Builder Integration (`lib/ckeditor5/rails/presets/preset_builder.rb`)

The upload adapter is configured through the preset system:

```ruby
def simple_upload_adapter(upload_url = '/uploads', compress: !@disallow_inline_plugin_compression)
  plugins do
    remove(:Base64UploadAdapter)  # Remove default Base64 adapter
  end
  
  plugin(Plugins::SimpleUploadAdapter.new(compress: compress))
  configure(:simpleUpload, { uploadUrl: upload_url })
end
```

**Location**: `lib/ckeditor5/rails/presets/preset_builder.rb:394-401`

**Configuration Steps**:
1. Removes the default Base64UploadAdapter plugin
2. Adds the SimpleUploadAdapter plugin
3. Configures the upload URL endpoint
4. Optionally enables/disables JavaScript compression

### Usage in Presets

Upload functionality is enabled in presets via:

```ruby
# In preset definition
simple_upload_adapter           # Uses default '/uploads' endpoint
simple_upload_adapter '/custom'  # Custom endpoint
```

**Example Location**: `sandbox/config/initializers/ckeditor5.rb:82`

## Frontend Implementation

### Upload Flow

1. **User Action**: User selects/pastes an image in the editor
2. **Plugin Activation**: FileRepository triggers createUploadAdapter
3. **Adapter Creation**: SimpleUploadAdapter creates an upload instance
4. **FormData Preparation**: File wrapped in FormData with 'upload' field name
5. **Security Headers**: 
   - X-Requested-With: XMLHttpRequest
   - X-CSRF-Token: Extracted from meta tag
6. **Upload Process**:
   - Progress events update loader.uploaded/uploadTotal
   - Success (200-299): Parse JSON response for URL
   - Error handling for failed/aborted uploads
7. **Editor Update**: Returned URL replaces placeholder image

### Response Format

Server must return JSON with structure:
```json
{
  "url": "https://example.com/uploads/image.jpg"
}
```

## Integration Points

### 1. Rails Controller

The upload endpoint (not included in gem) should:
- Accept POST requests to configured URL
- Process multipart/form-data with 'upload' field
- Store file using preferred backend (ActiveStorage, Shrine, etc.)
- Return JSON with uploaded file URL
- Handle CSRF token validation

### 2. Helper Methods

Upload configuration accessible via:
- `ckeditor5_editor` helper in views
- Preset configuration in initializers
- Runtime configuration overrides

**Location**: `lib/ckeditor5/rails/editor/helpers/editor_helpers.rb`

### 3. Engine Registration

Upload adapter available through:
- Engine preset system
- Direct plugin inclusion
- Configuration DSL methods

**Location**: `lib/ckeditor5/rails/engine.rb:83`

## File Structure

```
lib/ckeditor5/rails/
├── plugins/
│   ├── simple_upload_adapter.rb    # Main upload adapter implementation
│   └── ...
├── editor/
│   ├── props_inline_plugin.rb      # Base class for inline plugins
│   └── helpers/
│       └── editor_helpers.rb       # View helpers for editor
├── presets/
│   └── preset_builder.rb           # Configuration DSL with upload method
└── engine.rb                        # Rails engine with upload registration
```

## Configuration Examples

### Basic Setup

```ruby
CKEditor5::Rails.configure do
  # Enable with default /uploads endpoint
  simple_upload_adapter
end
```

### Custom Endpoint

```ruby
CKEditor5::Rails.configure do
  # Custom upload endpoint
  simple_upload_adapter '/api/images/upload'
end
```

### With Compression Disabled

```ruby
CKEditor5::Rails.configure do
  # Disable JavaScript compression for debugging
  simple_upload_adapter '/uploads', compress: false
end
```

## Key Implementation Details

### JavaScript Plugin Structure

The plugin is written as an ES6 module that:
1. Imports required CKEditor5 modules dynamically
2. Returns a class extending Plugin
3. Implements standard CKEditor5 plugin lifecycle
4. Integrates with FileRepository for upload management

### Security Considerations

- CSRF token automatically extracted from Rails meta tag
- XMLHttpRequest marked with X-Requested-With header
- Server-side validation responsibility lies with implementer

### Error Handling

- Network errors caught and rejected with descriptive messages
- HTTP status codes outside 200-299 range treated as errors
- Upload abort capability for user cancellation

## Backend Requirements

To implement the upload endpoint:

1. **Route Definition**: Add POST route to configured URL
2. **File Processing**: Handle multipart upload with 'upload' parameter
3. **Storage Backend**: Integrate with ActiveStorage, Shrine, or custom solution
4. **Response Format**: Return JSON with 'url' key
5. **Security**: Validate CSRF tokens and user permissions

## Extension Points

The system supports:
- Multiple upload adapters via plugin system
- Custom configuration through preset builder
- Backend flexibility through endpoint abstraction
- Compression toggle for development/production
- Integration with various storage backends

This architecture provides a clean separation between the editor frontend and storage backend, allowing developers to implement uploads using their preferred Rails patterns and storage solutions.