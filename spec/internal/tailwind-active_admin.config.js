const execSync = require('child_process').execSync;
const activeAdminPath = execSync('bundle show activeadmin', { encoding: 'utf-8' }).trim();

module.exports = {
  content: [
    `${activeAdminPath}/vendor/javascript/flowbite.js`,
    `${activeAdminPath}/plugin.js`,
    `${activeAdminPath}/app/views/**/*.{arb,erb,html,rb}`,
    './app/admin/**/*.{arb,erb,html,rb}',
    './app/views/active_admin/**/*.{arb,erb,html,rb}',
    './app/views/admin/**/*.{arb,erb,html,rb}',
    './app/javascript/**/*.js',
    './app/js/**/*.js'
  ],
  darkMode: "selector",
  plugins: [
    require(`@activeadmin/activeadmin/plugin`)
  ],
  // CRITICAL: Safelist for ActiveAdmin 4 dynamic classes
  safelist: [
    // Grid and layout
    'grid', 'gap-4', 'gap-6', 'lg:grid-cols-3', 'md:grid-cols-2',
    'col-span-2', 'col-span-3', 'lg:col-span-2', 'lg:col-span-1',
    // Flexbox
    'flex', 'flex-col', 'flex-row', 'flex-wrap', 'items-center',
    'justify-between', 'justify-center', 'items-start', 'items-end',
    // Spacing
    'p-4', 'p-6', 'px-4', 'px-6', 'py-2', 'py-4', 'm-0', 'mx-auto',
    'mt-4', 'mb-4', 'ml-auto', 'mr-auto', 'space-y-4', 'space-x-4',
    // Display
    'block', 'inline-block', 'hidden', 'lg:hidden', 'lg:block', 'lg:flex',
    // Width/Height
    'w-full', 'w-auto', 'w-64', 'h-full', 'min-h-screen', 'max-w-7xl',
    // Typography
    'text-sm', 'text-base', 'text-lg', 'text-xl', 'font-medium', 'font-semibold',
    // Colors
    'bg-white', 'bg-gray-50', 'bg-gray-100', 'text-gray-900', 'text-gray-600',
    'dark:bg-gray-800', 'dark:bg-gray-900', 'dark:text-white', 'dark:text-gray-300',
    // Borders
    'border', 'border-gray-200', 'dark:border-gray-700', 'rounded-lg', 'rounded-md',
    // Forms
    'form-input', 'form-select', 'form-checkbox',
    // Position & Z-index
    'relative', 'absolute', 'fixed', 'sticky', 'top-0', 'left-0', 'right-0',
    'z-10', 'z-20', 'z-30', 'z-40', 'z-50',
    // Shadows
    'shadow', 'shadow-md', 'shadow-lg',
    // Tables
    'table-auto', 'border-collapse',
    // Buttons
    'inline-flex', 'cursor-pointer'
  ]
}