(function() {
  define(function(require) {
    var baseMethods;
    return baseMethods = {
      onResolutionChanged: function(resolution) {
        var methodName;
        this.currentResolution = resolution.newSize;
        methodName = _.join('', 'onChangeFrom', _.str.capitalize(resolution.prevSize), 'To', _.str.capitalize(resolution.newSize));
        try {
          this[methodName]();
        } catch (_error) {}
      }
    };
  });

}).call(this);

//# sourceMappingURL=base.js.map
