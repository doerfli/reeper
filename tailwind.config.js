module.exports = {
    content: [
      './app/views/**/*.html.erb',
      './app/helpers/**/*.rb',
      './app/javascript/**/*.js'
    ],
    theme: {
      extend: {
        typography: (theme) => ({
          DEFAULT: {
            css: {

            },
          },
        }),
      },
    },
    plugins: [
      require('@tailwindcss/typography'),
      require('@tailwindcss/forms'),
    ],
  }
  