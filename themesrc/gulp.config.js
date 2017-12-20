module.exports = {
  app: {
    baseName: 'wendys'
  },
  sass: {
    src: [
      './wendys/styles/libraries/*.scss',
    ],
    lintSrc: [
      './wendys/styles/**/*.scss',
      './wendys/styles/**/**/*.scss'
    ]
  },
  javascript: {
    src: ['./wendys/scripts/**/*.js']
  },
  images: {
    src: ['./wendys/img/**/*']
  },
  fonts: {
    src: ['./wendys/fonts/*']
  },
  buildLocations: {
    css: '../docroot/themes/custom/wendys_main/dist/css',
    js: '../docroot/themes/custom/wendys_main/dist/js',
    img: '../docroot/themes/custom/wendys_main/dist/img',
    fonts: '../docroot/themes/custom/wendys_main/dist/fonts'
  }
};
