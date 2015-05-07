(function() {
  var s;

  s = require('underscore.string');

  module.exports = {
    onResolutionChanged: function(resolution) {
      var methodName;
      this.currentResolution = resolution.newSize;
      methodName = _.join('', 'onChangeFrom', s.capitalize(resolution.prevSize), 'To', s.capitalize(resolution.newSize));
      try {
        this[methodName]();
      } catch (_error) {}
    }
  };

}).call(this);

//# sourceMappingURL=base.js.map
