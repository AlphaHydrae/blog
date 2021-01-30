// Tailwind CSS Theme Configuration
// https://tailwindcss.com/docs/theme

const defaultTheme = require('tailwindcss/defaultTheme');

module.exports = {
  purge: [],
  darkMode: 'media', // or 'media' or 'class'
  theme: {
    extend: {
      fontFamily: {
        body: [ '"IBM Plex Serif"', ...defaultTheme.fontFamily.serif ],
        display: [ 'Comfortaa', ...defaultTheme.fontFamily.sans ],
        mono: [ '"Source Code Pro"', ...defaultTheme.fontFamily.mono ]
      }
    }
  },
  variants: {
    extend: {}
  },
  plugins: []
};
