(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(function(require) {
    var $, Backbone, SinglePageScrollingView, _;
    $ = require("jquery");
    _ = require("underscore");
    Backbone = require("backbone");
    return SinglePageScrollingView = (function(_super) {
      __extends(SinglePageScrollingView, _super);

      function SinglePageScrollingView() {
        return SinglePageScrollingView.__super__.constructor.apply(this, arguments);
      }

      SinglePageScrollingView.prototype.notifications = null;

      SinglePageScrollingView.prototype.currentResolution = null;

      SinglePageScrollingView.prototype.initialize = function(options) {
        var eventName;
        SinglePageScrollingView.__super__.initialize.call(this, options);
        try {
          this.currentResolution = this.options.currentResolution;
          this.notifications = this.options.notifications;
          this.notifications.on("controller:appLoaded", this.onAppLoaded);
          this.notifications.on("controller:resolutionChanged", this.onResolutionChanged);
        } catch (_error) {

        }
        if (_.has(this.options, 'pageName')) {
          eventName = ['controller', this.options.pageName, 'navigate'].join(':');
          return this.notifications.on(eventName, this.receiveNavigation);
        }
      };

      SinglePageScrollingView.prototype.render = function() {
        this.rendered = true;
        return this.trigger("rendered");
      };

      SinglePageScrollingView.prototype.afterRender = function() {
        this.sendNotification("sectionReady", this.options.pageName);
        this._setLocalUrlNavigate();
        return this.afterReady();
      };

      SinglePageScrollingView.prototype.afterReady = function() {
        return this.cleanup();
      };

      SinglePageScrollingView.prototype.cleanup = function() {
        this.off("rendered");
        return this.off("sectionReady");
      };

      SinglePageScrollingView.prototype.onAppLoaded = function() {
        return null;
      };

      SinglePageScrollingView.prototype.onResolutionChanged = function(resolution) {
        var methodName;
        this.currentResolution = resolution.newSize;
        methodName = ["onChangeFrom", Utilities.capitalize(resolution.prevSize), "To", Utilities.capitalize(resolution.newSize)].join("");
        try {
          this[methodName]();
        } catch (_error) {}
      };

      SinglePageScrollingView.prototype.sendNotification = function() {
        var args;
        args = [].slice.call(arguments);
        args[0] = 'view:' + args[0];
        return this.notifications.trigger.apply(this.notifications, args);
      };

      SinglePageScrollingView.prototype.sendNavigation = function(route) {
        return this.sendNotification('navigate', route);
      };

      SinglePageScrollingView.prototype.receiveNavigation = function(route) {
        return this.currentRoute = route;
      };

      SinglePageScrollingView.prototype._parseRoute = function(route) {
        var error;
        if (route === "" || route === "/") {
          return [];
        }
        try {
          return route.replace(/^\/|\/$/g, "").split("/");
        } catch (_error) {
          error = _error;
          return [];
        }
      };

      SinglePageScrollingView.prototype._setLocalUrlNavigate = function(contextObj) {
        if (_.isUndefined(contextObj)) {
          contextObj = this;
        }
        this.$el.find("a[href^=\"/\"]").not('[trigger-exclude]').on("click", _.bind(function(e) {
          e.preventDefault();
          e.stopPropagation();
          this.sendNavigation($(e.currentTarget).attr("href"));
        }, contextObj));
      };

      return SinglePageScrollingView;

    })(Backbone.View);
  });

}).call(this);

//# sourceMappingURL=view.js.map
