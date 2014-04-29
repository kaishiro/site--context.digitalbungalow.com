(function () {

  'use strict'

  var n;

  $(document).ready(function () {

    return $.getJSON('/locations.json', function(data) {

      var _i, _l, i;

      for (_i = 0, _l = data.length; _i < _l; _i++) {

        i = data[_i];
       
        var _city = i.city
        var _cityF = _city.toLowerCase();
        var _timezone = i.timezone;
        var _timezoneLong = i.timezone_long;
        var _localTime = moment().tz(_timezoneLong);
        var _localTimeF = _localTime.format("h:mma");
        var _locationStatus;

        var _localOpenTime = moment.tz(9, "HH", _timezoneLong);
        var _localCloseTime = moment.tz(17, "HH", _timezoneLong);

        if ((_localTime.isBefore(_localCloseTime)) && (_localTime.isAfter(_localOpenTime))) {
          _locationStatus = "location--open"
        }
        else {
          _locationStatus = "location--closed"
        }

        $('.location.location--' + _cityF + ' .location__time').html(_localTimeF);
        $('.location.location--' + _cityF).addClass(_locationStatus);
      }

    });

  }),

  n = {

    Toggle: {

      listeners: function() {
      },

      toggle_component: function(e) {
      }
    }
  }

}());
