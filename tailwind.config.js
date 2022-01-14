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
              lineHeight: '1.1',
              a: {
                textDecoration: 'none',
                padding: '0.25rem',
                borderRadius: '0.375rem',
              },
              'a:hover': {
                color: theme('colors.indigo.800'),
                backgroundColor: theme('colors.blue.200'),
              },
            },
          },
        }),
      },
    },
    plugins: [
      require('@tailwindcss/typography'),
    ],
  }
  