(function() {
  var _s;

  _s = require('underscore.string');

  module.exports = {
    onResolutionChanged: function(resolution) {
      var methodname;
      this.currentResolution = resolution.newSize;
      methodname = "onChangeFrom" + (_s.capitalize(resolution.prevSize)) + "To" + (_s.capitalize(resolution.newSize));
      try {
        this[methodName]();
      } catch (_error) {}
    }
  };

}).call(this);

//# sourceMappingURL=base.js.map
