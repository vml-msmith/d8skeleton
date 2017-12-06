<?php

/**
 * @file
 * Front end build system.
 */

require_once "spyc.php";


$errors = array();


$environment_files = array(
  'environment.yml',
  '../environment.yml',
  '/var/www/environment.yml'
);

foreach ($environment_files as $env_yml) {
  if (file_exists($env_yml)) {
    print 'Loading ' . $env_yml . "...\n";
    $config = Spyc::YAMLLoad($env_yml);

    if (isset($config['theme_builder']['base'])) {
      $config['theme_builder']['base'] = rtrim($config['theme_builder']['base'], '/');
    }
    else {
      $config['theme_builder']['base'] = '.';
    }

    break;
  }
}

if (!isset($config['theme_builder'])) {
  PrettyPrint::p("No theme_builder settings found in environment.yml");
  exit();
}

/**
 * Pretty printing class.
 */
class PrettyPrint {

  /**
   * Pretty Printer.
   */
  public static function p($val, $level = 0) {
    $spaces = '';
    for ($i = 0; $i < $level; ++$i) {
      $spaces .= ' ';
    }

    if (is_array($val)) {
      foreach ($val as $value) {
        echo $spaces . $value . "\n";
      }
    }
    else {
      echo $spaces . $val . "\n";
    }
  }

  /**
   * Pretty Header.
   */
  public static function header($str) {
    echo "#########################################\n";
    echo "## " . $str . "\n";
    echo "#########################################\n";
  }

  /**
   * Pretty Footer.
   */
  public static function footer() {
    echo "\n\n";
  }

}

/**
 * Ensures command is installed.
 */
function ensure_installed($program, $command) {
  if (!`which $program`) {
    PrettyPrint::p("Installing " . ucwords($program) . "...");
    shell_exec($command);
  }
}

$options = array();

$parameter_map = array(
  'process' => 'p',
  'theme' => 't'
);

foreach ($argv as $arg) {
  // Skip non assignment arguments.
  if (strpos($arg, '=') === FALSE) {
    continue;
  }
  list($var, $val) = explode('=', $arg);
  // Remove preceding dashes.
  $var = ltrim($var, '-');
  // Reduce long parameters to short versions.
  if (in_array($var, array_keys($parameter_map))) {
    $var = $parameter_map[$var];
  }
  // Set option.
  if (!isset($options[$var])) {
    $options[$var] = $val;
  }
  elseif (is_array($options[$var])) {
    $options[$var][] = $val;
  }
  else {
    $options[$var] = array($options[$var]);
    $options[$var][] = $val;
  }
}

if (!isset($options['p'])) {
  PrettyPrint::p("Running with default processes npm, bower, gulp-build.");
  $options['p'] = array('npm', 'bower', 'gulp-build');
}

// Arrayify the options.
if (!is_array($options['p'])) {
  $options['p'] = array($options['p']);
}
if (isset($options['t']) && !is_array($options['t'])) {
  $options['t'] = array($options['t']);
}

$allowed_processes = array(
  'npm',
  'npm-rebuild',
  'bower',
  'gulp-build',
  'gulp-build-dev',
  'gulp-watch'
);

if (count(array_diff($options['p'], $allowed_processes)) >= 1) {
  PrettyPrint::p("Unknown process '" . implode(', ', array_diff($options['p'], $allowed_processes)) . "' specified. try using -p=[" . implode('|', $allowed_processes) . "]");
  exit();
}

// Constraints for gulp-watch process.
if (in_array('gulp-watch', $options['p']) && count($options['t']) !== 1) {
  PrettyPrint::p("Process 'gulp-watch' requires one, and only one, theme to be specified. use -t=[theme_name]");
  exit();
}

$npm_version = 'v6.9.1';
if (isset($config['theme_builder']['npm_version'])) {
  $npm_version = $config['theme_builder']['npm_version'];
  $cmd_prefix = 'source /usr/local/nvm/versions/node/v4.2.3/bin/nvm.sh && nvm install ' . $npm_version . '  && nvm use ' . $npm_version . ' &&';
}
else {
  $cmd_prefix = '';
}

// Theme loop.
foreach ($config['theme_builder']['themes'] as $theme => $theme_opt) {
  // Ignore theme if specified and not matching.
  if (isset($options['t']) && !in_array($theme, $options['t'])) {
    continue;
  }
  PrettyPrint::header('Processing ' . $theme);

  $cd_theme = 'cd /var/www/' . $config['theme_builder']['base'] . '/' . $theme;

  // Bower.
  if (in_array('bower', $options['p']) && in_array('bower', $theme_opt)) {
    PrettyPrint::p("Running Bower...");

    ensure_installed('bower', $cmd_prefix . 'npm install -g --silent bower');

    $command = $cd_theme . ' && ' . $cmd_prefix . 'bower install --allow-root';
    $output = '';
    $response = 0;

    ob_start();
    exec($command, $output, $response);
    ob_end_clean();

    if ($response !== 0) {
      PrettyPrint::p('Bower install failed!');
      exit(1);
    }
    else {
      PrettyPrint::p("Done!");
    }
  }

  // NPM.
  if (in_array('npm', $options['p']) && in_array('npm', $theme_opt)) {
    PrettyPrint::p("Running NPM");

    $command = $cd_theme . ' && ' . $cmd_prefix . 'npm install';
    $output = '';
    $response = 0;

    ob_start();
    exec($command, $output, $response);
    ob_end_clean();

    if ($response !== 0) {
      PrettyPrint::p('NPM install failed!');
      exit(1);
    }
    else {
      PrettyPrint::p("Done!");
    }
  }
  // NPM.
  if (in_array('npm-rebuild', $options['p']) && in_array('npm', $theme_opt)) {
    PrettyPrint::p("Rebuilding NPM");

    $command = $cd_theme . ' && rm -rf node_modules && ' . $cmd_prefix . 'npm install';
    $output = '';
    $response = 0;

    ob_start();
    exec($command, $output, $response);
    ob_end_clean();

    if ($response !== 0) {
      PrettyPrint::p('NPM rebuild failed!');
      exit(1);
    }
    else {
      PrettyPrint::p("Done!");
    }
  }
  // Gulp Build.
  if (in_array('gulp-build', $options['p']) && in_array('gulp', $theme_opt)) {
    PrettyPrint::p("Running Gulp Build...");
    ensure_installed('gulp', $cmd_prefix . 'npm install -g --silent gulp gulp-cli');
    $command = $cd_theme . ' && ' . $cmd_prefix . 'gulp build';
    passthru($command);
  }
  // Gulp Build Dev.
  if (in_array('gulp-build-dev', $options['p']) && in_array('gulp', $theme_opt)) {
    PrettyPrint::p("Running Gulp Build Dev...");
    ensure_installed('gulp', $cmd_prefix . 'npm install -g --silent gulp gulp-cli');
    $command = $cd_theme . ' && ' . $cmd_prefix . 'gulp build--dev';
    passthru($command);
  }
  // Gulp Watch.
  if (in_array('gulp-watch', $options['p']) && in_array('gulp', $theme_opt)) {
    PrettyPrint::p("Running Gulp Watch...");
    ensure_installed('gulp', $cmd_prefix . 'npm install -g --silent gulp gulp-cli');
    $command = $cd_theme . ' && ' . $cmd_prefix . 'gulp watch';
    passthru($command);
  }
}

exit;
