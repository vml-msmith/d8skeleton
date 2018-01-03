<?php

namespace Drupal\wendys_theme\Controller;
use Drupal\Core\Controller\ControllerBase;
use Drupal\Core\Cache\CacheableResponse;
use Drupal\Component\Utility\Html;

/**
 * Controller object for CptApi.
 */
class BrandCssController extends ControllerBase {

  /**
   */
  public function content() {
    $content = '';

    $terms = \Drupal::service('entity_type.manager')
      ->getStorage("taxonomy_term")
      ->loadTree('menu_icons', 0, NULL, TRUE);


    $content = '';
    foreach ($terms as $term) {
      $field = $term->get('field_icon');
      if ($field) {
        $name = strtolower(Html::cleanCssIdentifier($term->getName()));
        $file = \Drupal\file\Entity\File::load($field->getValue()[0]['target_id']);
        $data = file_get_contents($file->getFileUri());
        $img = base64_encode($data);
        $content .= ' .menu-icon.icon--' . $name . ':before { background-image: url(\'data:image/svg+xml;base64,' . $img . '\'); }';
      }

    }

    $terms = \Drupal::service('entity_type.manager')
      ->getStorage("taxonomy_term")
      ->loadTree('brand_colors', 0, NULL, TRUE);


    foreach ($terms as $term) {
      $color_field = $term->get('field_brandcolors_color');
      $name = strtolower(Html::cleanCssIdentifier($term->getName()));

      if ($color_field) {
        $content .= ' .brand-color--background--' . $name . ' { background-color: ' . $color_field->value  . '; }';
        $content .= ' .brand-color--text--' . $name . ' { color: ' . $color_field->value  . '; }';
      }
    }

    $response = new CacheableResponse();
    $response->headers->set('Content-Type', 'text/css');
    $response->setContent($content);
    $response->setMaxAge(10);
    return $response;
  }
}
