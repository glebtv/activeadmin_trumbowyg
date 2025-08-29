// Main entry point for activeadmin_trumbowyg gem
// This file is resolved when users import 'activeadmin_trumbowyg'
// It forwards to the ESM version which handles dependencies and initialization

import './active_admin/trumbowyg.esm';

// Export the main functions for direct usage if needed
export { initTrumbowygEditors, updateEditorsTheme } from './active_admin/trumbowyg.esm';