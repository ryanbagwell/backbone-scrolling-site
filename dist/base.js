(function() {
  define(function(require) {
    var Base;
    return Base = (function() {
      function Base() {}

      Base.prototype.onResolutionChanged = function(resolution) {
        var methodName;
        this.currentResolution = resolution.newSize;
        methodName = _.join('', 'onChangeFrom', _.str.capitalize(resolution.prevSize), 'To', _.str.capitalize(resolution.newSize));
        try {
          this[methodName]();
        } catch (_error) {}
      };

      return Base;

    })();
  });

}).call(this);

//# sourceMappingURL=base.js.map
