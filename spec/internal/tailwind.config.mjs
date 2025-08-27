import activeAdminPlugin from '@activeadmin/activeadmin/plugin'
import { execSync } from 'node:child_process'

let activeAdminPath = null
try {
  activeAdminPath = execSync('bundle show activeadmin', { encoding: 'utf8' }).trim()
} catch (e) {
  // If bundler is unavailable at build time, we still build without scanning AA views
}

export default {
  content: [
    './app/admin/**/*.{arb,erb,html,rb}',
    './app/views/**/*.{arb,erb,html,rb}',
    './app/javascript/**/*.js',
    './app/js/**/*.js',
    ...(activeAdminPath ? [
      `${activeAdminPath}/vendor/javascript/flowbite.js`,
      `${activeAdminPath}/plugin.js`,
      `${activeAdminPath}/app/views/**/*.{arb,erb,html,rb}`,
    ] : [])
  ],
  darkMode: 'selector',
  theme: {
    extend: {},
  },
  plugins: [activeAdminPlugin],
}
