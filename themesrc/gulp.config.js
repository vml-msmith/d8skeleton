module.exports = {
  app: {
    baseName: 'theme'
  },
  sass: {
    src: [
      './theme/styles/libraries/*.scss',
    ],
    lintSrc: [
      './theme/styles/**/*.scss',
      './theme/styles/**/**/*.scss'
    ]
  },
  javascript: {
    src: ['./theme/scripts/**/*.js']
  },
  images: {
    src: ['./theme/img/**/*']
  },
  fonts: {
    src: ['./theme/fonts/*']
  },
  buildLocations: {
    css: '../docroot/themes/custom/main/dist/css',
    js: '../docroot/themes/custom/main/dist/js',
    img: '../docroot/themes/custom/main/dist/img',
    fonts: '../docroot/themes/custom/main/dist/fonts'
  }
};
