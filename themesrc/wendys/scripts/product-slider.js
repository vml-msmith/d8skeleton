/**
 * @file
 */

/* global Drupal */
/* global jQuery */


(function ($) {

  'use strict';
  Drupal.behaviors.productSlider = {
    attach: function (context, settings) {
      $('.product-slider .tray').once('product-slider-setup').each(function () {
        $(this).scroll(function (e) {
          console.log(e);
        });
      });
    }
  };
}(jQuery));
