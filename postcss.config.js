module.exports = {
  plugins: [
      require("postcss-import"),
      require("@tailwindcss/postcss"),
      require("postcss-url")({
        url: ({ url }) => {
          if (url.includes("@fortawesome/fontawesome-free/webfonts/")) {
            const file = url.split("/").pop();
            return `/webfonts/${file}`;
          }
          return url;
        }
      })
  ]
}
