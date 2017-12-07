'use strict';

var gulp = require('gulp-help')(require('gulp'), { hideDepsMessage: true, afterPrintCallback: cliNotes });
var bs = require('browser-sync').create();
var gulpUtil = require('gulp-util');
var concat = require('gulp-concat');
var rename = require('gulp-rename');
var sourcemaps = require('gulp-sourcemaps');
var del = require('del');
var sass = require('gulp-sass');
var sassLint = require('gulp-sass-lint');
var eslint = require('gulp-eslint');
var changed = require('gulp-changed');
var runSequence = require('run-sequence');
var merge = require('merge-stream');
var include = require('gulp-include');
var Stream = require('stream');

var CONFIGS = [require('./gulp.config.wendys.js')];

gulp.task('default', false, ['help']);

gulp.task('build', 'Production ready build for client code.', (done) => {
    gulpUtil.env.type = 'production';
    gulpUtil.env.build_type = 'build';
    build(done);
});

gulp.task('build--dev', 'Development ready build for client code.', (done) => {
    gulpUtil.env.type = 'development';
    gulpUtil.env.build_type = 'build';
    build(done);
});

gulp.task('watch', 'Watch source files for changes and build on update', ['build--dev'], () => {
    gulpUtil.env.type = 'development';
    gulpUtil.env.build_type = 'watch';

    var jsSrc = [];
    var sassSrc = [];

    CONFIGS.forEach(config => {
        jsSrc.push(config.javascript.src);
        sassSrc.push(config.sass.src);
    });

    gulp.watch(sassSrc, () => runSequence('_build.sass', '_sass-lint'));
    gulp.watch(jsSrc, () => runSequence('_build.javascript', '_js-lint'));
});

gulp.task('_build.javascript', 'Build JavaScript and move to distribute', () => {
    var tasks = CONFIGS.map(config => {
        return gulp.src(config.javascript.src)
            .pipe(include()).on('error', console.log)
            .pipe(isBuild() ? gulpUtil.noop() : changed(config.buildLocations.js))
            .pipe(isProd() ? gulpUtil.noop() : sourcemaps.init())
            .pipe(isProd() ? gulpUtil.noop() : sourcemaps.write('./maps'))
            .pipe(gulp.dest(config.buildLocations.js));
    });

    return merge(tasks);
});

gulp.task('_sass-lint', 'Lint Sass to check for style errors', () => {
    var tasks = CONFIGS.map(config => {
        return gulp.src(config.sass.lintSrc)
        .pipe(sassLint({
          sasslintConfig: '.sass-lint.yml'
        }))
        .pipe(sassLint.format())
        .pipe(sassLint.failOnError())
        .on('error', swallowError);
    });

    return merge(tasks);
});

gulp.task('_js-lint', 'Lint JS to check for style errors', () => {
    var tasks = CONFIGS.map(config => {
        return gulp.src(config.javascript.src)
        .pipe(eslint())
        .pipe(eslint.format())
        .pipe(eslint.failAfterError())
        .on('error', swallowError);
    });

    return merge(tasks);
});

gulp.task('_build.sass', 'Build Sass and compile out CSS', () => {
    var tasks = CONFIGS.map(config => {
        return gulp.src(config.sass.src)
            .pipe(isProd() ? gulpUtil.noop() :  sourcemaps.init())
            .pipe(isProd() ? sass({
            }) : sass({
              noCache: true,
              lineNumbers: false,
              sourceMap: true
            }).on('error', swallowError))
            .pipe(isProd() ? gulpUtil.noop() : sourcemaps.write('./maps'))
            .on('error', swallowError)
            .pipe(gulp.dest(config.buildLocations.css));
    });

    return merge(tasks);
});

gulp.task('_build.images', 'Compress and distribute images', () => {
    var tasks = CONFIGS.map(config => {
        return gulp.src(config.images.src)
                .pipe(changed(config.buildLocations.img))
                .pipe(gulp.dest(config.buildLocations.img));
    });

    return merge(tasks);
});

gulp.task('_build.copyfonts', () => {
    var tasks = CONFIGS.map(config => {
        return gulp.src(config.fonts.src)
                .pipe(changed(config.buildLocations.fonts))
                .pipe(gulp.dest(config.buildLocations.fonts));
    });
    return merge(tasks);
});

function build(done) {
    runSequence(
        ['_build.images', '_build.javascript', '_js-lint', '_build.sass', '_sass-lint', '_build.copyfonts'],
        done
    );
}

function swallowError(error) {
    console.log(error.toString());

    this.emit('end');
}

function isProd() {
    return gulpUtil.env.type === 'production';
}
function isBuild() {
    return gulpUtil.env.build_type === 'build';
}

function cliNotes() {
    console.log('  * _tasks are private sub tasks. Only use if necessary. *\n\n\n');
}
