<?php

/**
 * @file
 * Lint Running System.
 */

class Input {
  public $options;
  public $inputString;

  protected function setDefaultOptions() {
    $this->options = array();
  }

  public function __construct($args) {
    $this->setDefaultOptions();
    $inOptions = TRUE;
    $inputString = "";

    foreach ($args as $i => $val) {
      $val = trim($val);

      if (!$val || $val === 'php' || $i === 0) {
        continue;
      }

      if ($inOptions == TRUE && strpos($val, '--') === 0) {
        print_r(array("option: " . $val . "\n"));
      }
      else {
        $inOptions = FALSE;
        $inputString .= " " . $val;
      }
    }
    $this->inputString = trim($inputString);
  }

}

/**
 * File list class.
 */
class FileList {
  public $files;

  public function __construct($string, $path) {
    $this->files['all'] = explode(' ', $string);
    $this->files['all'] = array_map(function ($item) {
      return '/var/www/' . $item;
    }, $this->files['all']);

    $this->expandDirectories();

    $this->filterIgnoredFiles();
    $this->filterPhpFiles();
    $this->filterCssFiles();
    $this->filterJsFiles();
  }

  /**
   * Filter ignored files from config file.
   */
  public function filterIgnoredFiles() {
    require_once "spyc.php";
    $config = Spyc::YAMLLoad('/var/www/environment.yml');

    $lint_ignore = array_map(function ($item) {
      return '/var/www/' . $item;
    }, $config['lint_ignore']);

    foreach ($lint_ignore as $pattern) {
      $preg_opt = array('\*' => '.*', '\?' => '.', '\[' => '[', '\]' => ']');
      $escaped_pattern = "#^" . strtr(preg_quote(trim($pattern), '#'), $preg_opt) . "(.*)$#i";
      $escaped_pattern = str_replace('/', '\/', $escaped_pattern);
      $this->ignorePatterns[] = $escaped_pattern;
    }

    foreach ($this->ignorePatterns as $pattern) {
      $this->files['all'] = array_diff($this->files['all'], preg_grep($pattern, $this->files['all']));
    }
  }

  /**
   * Filter for PHP CS files.
   */
  protected function filterPhpFiles() {
    $response = array_filter(
        $this->files['all'],
        function ($item) {
          return preg_match("/.\.(php|module|inc|install)/i", $item);
        }
    );
    $this->files['php'] = $response;
  }

  /**
   * Filter for CSS related files.
   */
  protected function filterCssFiles() {
    $response = array_filter(
        $this->files['all'],
        function ($item) {
          return preg_match("/.\.(css|scss|sass)/i", $item);
        }
    );
    $this->files['css'] = $response;
  }

  /**
   * Filter for JS related files.
   */
  protected function filterJsFiles() {

    $response = array_filter(
        $this->files['all'],
        function ($item) {
          return preg_match("/.\.(js)/i", $item);
        }
    );
    $this->files['js'] = $response;
  }

  protected function expandDirectories() {
    $new_files = [];
    foreach ($this->files['all'] as $key => $file) {
      if (is_dir($file)) {
        $new_files += $this->getDirFiles($file);
      }
    }
    $this->files['all'] += $new_files;
  }

  protected function getDirFiles($dir, $results = []) {
    $files = scandir($dir);

    foreach ($files as $key => $value) {
      $path = realpath($dir . DIRECTORY_SEPARATOR . $value);
      if (!is_dir($path)) {
        $results[] = $path;
      }
      elseif ($value != "." && $value != "..") {
        $results += $this->getDirFiles($path, $results);
      }
    }

    return $results;
  }

}
/**
 * Pretty printing class.
 */
class PrettyPrint {

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

  public static function header($str) {
    echo "#########################################\n";
    echo "## " . $str . "\n";
    echo "#########################################\n";
  }

  public static function footer() {
    echo "\n\n";
  }

}
/**
 * PHP tester class.
 */
class PHPTester {

  /**
   * PHP syntax testing.
   */
  protected static function testSyntax($files) {

    $testResponse = array();
    PrettyPrint::header("Testing PHP Syntax");
    foreach ($files as $file) {
      $output = '';
      $response = 0;

      ob_start();
      exec("php -l -d display_errors=0 $file", $output, $response);
      ob_end_clean();

      if ($response !== 0) {
        echo "Detected PHP syntax errors in file: $file\n";
        PrettyPrint::p($output, 2);
        $testResponse[$file] = $file;
      }
    }

    PrettyPrint::footer();

    return $testResponse;
  }

  /**
   * PHP codesniffer.
   */
  protected static function testPhpCs($files) {

    $testResponse = array();

    PrettyPrint::header("Testing PHPCS: Standards");

    $output = '';
    $fileString = implode(' ', $files);

    $drupalStandards = '/root/.composer/vendor/drupal/coder/coder_sniffer/Drupal';
    exec("/root/.composer/vendor/squizlabs/php_codesniffer/scripts/phpcs --standard=$drupalStandards --encoding=utf8 -n -p $fileString", $output, $response);

    PrettyPrint::p($output);
    if ($response !== 0) {
      $testResponse['drupal'] = 'drupal';
    }

    PrettyPrint::header("Testing PHPCS: Best Practice");

    $output = '';
    $drupalStandards = '/root/.composer/vendor/drupal/coder/coder_sniffer/DrupalPractice';
    exec("/root/.composer/vendor/squizlabs/php_codesniffer/scripts/phpcs --standard=$drupalStandards --encoding=utf8 -n -p $fileString", $output, $response);

    PrettyPrint::p($output);
    if ($response !== 0) {
      $testResponse['bp'] = 'bp';
    }

    return $testResponse;
  }

  public static function test($files) {
    $response = array();
    $response += static::testSyntax($files);
    $response += static::testPhpCs($files);
    return $response;
  }

}

/**
 * Javascript test class.
 */
class JSTester {

  /**
   * ESLint testing.
   */
  protected static function testEslint($files) {

    $testResponse = array();
    exec("npm install -g eslint-config-airbnb");
    exec("npm install -g eslint-plugin-jsx-a11y");
    exec("npm install -g eslint-plugin-react");
    PrettyPrint::header("Testing ESLint");
    foreach ($files as $file) {
      $output = '';
      $response = 0;

      ob_start();
      exec("eslint $file", $output, $response);
      ob_end_clean();

      if ($response !== 0) {
        PrettyPrint::p($output, 2);
        $testResponse[$file] = $file;
      }
    }

    PrettyPrint::footer();

    return $testResponse;
  }

  public static function test($files) {
    $response = array();
    $response += static::testEslint($files);
    return $response;
  }

}

$input = new Input($argv);

if (!$input->inputString) {
  exit();
}

$fileList = new FileList($input->inputString, '/var/www/');

$files = $fileList->files['all'];
$php = $fileList->files['php'];
$js = $fileList->files['js'];

$errors = array();
if ($php) {
  $errors += PHPTester::test($php);
}

if ($js) {
  $errors += JSTester::test($js);
}

exit(count($errors));
