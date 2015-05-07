(function() {
  var $, Backbone, Base, SinglePageScrollingView, _,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  $ = require("jquery");

  _ = require("underscore");

  _.str = require('underscore.string');

  _.mixin(_.str.exports());

  Base = require('./base');

  Backbone = require("backbone");

  module.exports = SinglePageScrollingView = (function(superClass) {
    extend(SinglePageScrollingView, superClass);

    function SinglePageScrollingView() {
      return SinglePageScrollingView.__super__.constructor.apply(this, arguments);
    }

    SinglePageScrollingView.prototype.tagName = 'section';

    SinglePageScrollingView.prototype.notifications = null;

    SinglePageScrollingView.prototype.currentResolution = null;

    SinglePageScrollingView.prototype.ready = false;

    SinglePageScrollingView.prototype.initialize = function(options) {
      var eventName, method, name, notifications;
      this.options = _.extend({}, options);
      for (name in Base) {
        method = Base[name];
        this[name] = _.bind(method, this);
      }
      SinglePageScrollingView.__super__.initialize.call(this, options);
      this.on('rendered', _.bind(this.afterRender, this));
      try {
        this.currentResolution = this.options.currentResolution;
        notifications = this.options.notifications;
        return this.notifications.on({
          "controller:appLoaded": this.onAppLoaded,
          "controller:resolutionChanged": this.onResolutionChanged
        }, this);
      } catch (_error) {
        if (_.has(this.options, 'pageName')) {
          eventName = ['controller', this.options.pageName, 'navigate'].join(':');
          return this.notifications.on(eventName, (function(_this) {
            return function(route) {
              return _this.receiveNavigation(route);
            };
          })(this));
        }
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

}).call(this);

//# sourceMappingURL=view.js.map
