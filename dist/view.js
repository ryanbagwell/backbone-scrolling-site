(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(function(require) {
    var $, Backbone, Base, SinglePageScrollingView, _;
    $ = require("jquery");
    _ = require("underscore");
    _.str = require('underscore.string');
    _.mixin(_.str.exports());
    Base = require('./base');
    Backbone = require("backbone");
    return SinglePageScrollingView = (function(_super) {
      __extends(SinglePageScrollingView, _super);

      function SinglePageScrollingView() {
        return SinglePageScrollingView.__super__.constructor.apply(this, arguments);
      }

      SinglePageScrollingView.prototype.notifications = null;

      SinglePageScrollingView.prototype.currentResolution = null;

      SinglePageScrollingView.prototype.ready = false;

      SinglePageScrollingView.prototype.initialize = function(options) {
        var eventName, method, name;
        this.options = _.extend({}, options);
        for (name in Base) {
          method = Base[name];
          this[name] = method;
        }
        SinglePageScrollingView.__super__.initialize.call(this, options);
        this.on('rendered', _.bind(this.afterRender, this));
        try {
          this.currentResolution = this.options.currentResolution;
          this.notifications = this.options.notifications;
          this.notifications.on({
            "controller:appLoaded": this.onAppLoaded,
            "controller:resolutionChanged": this.onResolutionChanged
          }, this);
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
        this.ready = true;
        this.sendNotification("sectionReady", this.options.pageName);
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

      return SinglePageScrollingView;

    })(Backbone.View);
  });

}).call(this);

//# sourceMappingURL=view.js.map
