(function() {
  var _s;

  _s = require('underscore.string');

  module.exports = {
    onResolutionChanged: function(resolution) {
      var methodName;
      this.currentResolution = resolution.newSize;
      methodName = _s.join('', 'onChangeFrom', s.capitalize(resolution.prevSize), 'To', s.capitalize(resolution.newSize));
      try {
        this[methodName]();
      } catch (_error) {}
    }
  };

}).call(this);

//# sourceMappingURL=base.js.map
