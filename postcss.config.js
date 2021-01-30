// PostCSS
// https://postcss.org

module.exports = {
  plugins: [
    require('tailwindcss'),
    require('autoprefixer'),
    ...(process.env.JEKYLL_ENV == 'production' // example of only using a plugin in production
      ? [require('cssnano')({ preset: 'default' })]
      : [])
  ]
};
