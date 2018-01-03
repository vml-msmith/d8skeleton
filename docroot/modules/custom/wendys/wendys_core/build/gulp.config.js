module.exports = {
  app: {
    baseName: 'wendys'
  },
  sass: {
    src: [
      './styles/*.scss',
    ],
    lintSrc: [
      './styles/**/*.scss',
      './styles/**/**/*.scss'
    ]
  },
  javascript: {
    src: ['./js/**/*.js']
  },
  images: {
    src: ['./img/**/*']
  },
  fonts: {
    src: ['./fonts/*']
  },
  buildLocations: {
    css: '../css',
    js: '../js',
    img: '../img',
    fonts: '../fonts'
  }
};
