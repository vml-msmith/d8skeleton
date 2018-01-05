/**
 * @file
 */

(function ($) {
  Drupal.behaviors.wendys_authentication = {
    attach(context, settings) {
      /*
      const rawCookie = Cookies.get('wenGlobalWeb');

      if (rawCookie) {
        const parsedCookie = JSON.parse(rawCookie);

        if (parsedCookie.user) {
          $('.default > .replace-name').once('test').html(`<div>Your Account</div><div>Hello ${parsedCookie.user.firstName}</div>`);
          $('.mobile > .replace-name').once('test').html(`<div>Hello ${parsedCookie.user.firstName[0]}. </div>`);
        }

        if (parsedCookie.selectedLocation) {
          $('.default > .replace-location').once('test').html(`<div>Find a Wendy's</div><div>${parsedCookie.selectedLocation.title}</div>`);
        }
      }
      */
      /*
      $('span[data-replace="account-balance"]', context).each(function() {

        if (raw_cookie === undefined) {
          $(this).replaceWith('');
          return;
        }

        var parsed_cookie = JSON.parse(window.atob(raw_cookie));
        var balance = parsed_cookie["balance"];
        balance = parseFloat(Math.round(balance * 100) / 100).toFixed(2);

        $(this).replaceWith('<span class="final-account-balance">' + balance + '</span>');
      });
      */
    },
  };
}(jQuery));
