/**
 * @file
 */

(function ($) {
  'use strict';

  Drupal.behaviors.wendys = {
    attach: function (context, settings) {
      $(window).on("scroll", function() {
        if ($('html').scrollTop() >= 160) {
          $('header').addClass('closed');
        }
        else {
          $('header.closed').removeClass('closed');
        }
      });
    }
  };
}(jQuery));
