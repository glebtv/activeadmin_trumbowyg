import activeAdminPlugin from '@activeadmin/activeadmin/plugin'

export default {
  content: [
    './app/admin/**/*.{arb,erb,html,rb}',
    './app/views/**/*.{arb,erb,html,rb}',
    './app/javascript/**/*.js',
    './app/js/**/*.js'
  ],
  darkMode: 'selector',
  theme: {
    extend: {},
  },
  plugins: [activeAdminPlugin],
}

