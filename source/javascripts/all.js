(function () {

  'use strict'

  var n;

  $(document).ready(function () {

    n.Toggle.listeners();
    n.Hover.listeners();

  }),

  n = {

    Hover: {
      listeners: function() {
        // $('.hover').hover(n.Hover.hover_component);
      },

      hover_component: function(e) {
      }
    },

    Toggle: {

      listeners: function() {
        // $('.toggle').on('click', n.Toggle.toggle_component);
      },

      toggle_component: function(e) {
      }
    }
  }

}());
