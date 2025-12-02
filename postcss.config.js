module.exports = {
  plugins: [
      require("postcss-import"),
      require("@tailwindcss/postcss"),
      require("postcss-url")({
        url: (asset) => {
          // Rewrite FontAwesome webfont paths to point to /webfonts in public directory
          if (asset.url.includes('webfonts/')) {
            return asset.url.replace(/.*webfonts\//, '/webfonts/');
          }
          return asset.url;
        }
      })
  ]
}
