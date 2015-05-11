(function() {
  var $, Backbone, Base, SinglePageScrollingController, SinglePageScrollingView, _, _s,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  $ = require('jquery');

  _ = require('underscore');

  _s = require('underscore.string');

  Backbone = require('backbone');

  Base = require('./base');

  require('jquery.scrollto');

  SinglePageScrollingView = require('./view');

  module.exports = SinglePageScrollingController = (function(_super) {
    __extends(SinglePageScrollingController, _super);

    function SinglePageScrollingController() {
      return SinglePageScrollingController.__super__.constructor.apply(this, arguments);
    }

    SinglePageScrollingController.prototype.sections = {};

    SinglePageScrollingController.prototype.loadAync = true;

    SinglePageScrollingController.prototype.resolutionBreakPoints = [
      {
        name: 'large',
        min: 1200,
        max: 100000000
      }, {
        name: 'medium',
        min: 992,
        max: 1199
      }, {
        name: 'small',
        min: 768,
        max: 991
      }, {
        name: 'extraSmall',
        min: 0,
        max: 767
      }
    ];

    SinglePageScrollingController.prototype.currentResolution = 0;

    SinglePageScrollingController.prototype.previousResolution = 0;

    SinglePageScrollingController.prototype.notifications = _.clone(Backbone.Events);

    SinglePageScrollingController.prototype.ready = false;

    SinglePageScrollingController.prototype.scrolling = false;

    SinglePageScrollingController.prototype.navigationOffset = 0;

    SinglePageScrollingController.prototype.defaultOptions = {
      debug: false,
      scrollTime: 500,
      scrollToOptions: {},
      navigateOnManualScroll: true
    };

    SinglePageScrollingController.prototype.initialize = function(options) {
      var method, name;
      this.options = _.extend(this.defaultOptions, options);
      for (name in Base) {
        method = Base[name];
        this[name] = _.bind(method, this);
      }
      SinglePageScrollingController.__super__.initialize.call(this, options);
      _.each(this.sections, function(section, name) {
        if (_.isUndefined(section.route)) {
          return;
        }
        return this.route(section.route, function() {
          return null;
        });
      }, this);
      this._resolutionChanged();
      this.pageMetaCollection = new Backbone.Collection(this.options.pageMeta);
      this.notifications.on('controller:resolutionChanged', this.onResolutionChanged, this);
      this.notifications.on('view:sectionReady', this.appLoaded, this);
      this.notifications.on('view:navigate', this.navigate, this);
      $(window).on('resize', _.bind(_.debounce(function() {
        return this.notify('windowResized');
      }, 500), this));
      $(window).on('orientationchange', function() {
        return $(window).trigger('resize');
      });
      $(window).on('resize', _.bind(this._resolutionChanged, this));
      _.each(this.sections, function(params, name, sections) {
        if (_.has(params, 'route')) {
          return this.route(params.route, name, this.navigate);
        }
      }, this);
      Backbone.history.start({
        pushState: true,
        silent: true
      });
      $('body').on('click', 'a[href^="/"]:not([data-nobind]), body a[href^="' + window.location.origin + '"]:not([data-nobind])', (function(_this) {
        return function(e) {
          _this.navigate($(e.currentTarget).attr('href'));
          return false;
        };
      })(this));
      return _.each(this.sections, this.loadSection, this);
    };

    SinglePageScrollingController.prototype.navigate = function(route, options) {
      var id, section;
      if (!this.ready) {
        return;
      }
      options = _.extend({
        trigger: false,
        scroll: true
      }, options);
      SinglePageScrollingController.__super__.navigate.call(this, _s.ltrim(route, '/'), options);
      this.updatePageMeta(route);
      section = this._fragmentToSection(_.ltrim(route, '/'));
      this.currentSection = section;
      id = section.instance.options.pageName;
      if (options.scroll !== false) {
        this.scrollToSection(id);
      }
      return this.notify(id + ':navigate', route);
    };

    SinglePageScrollingController.prototype.scrollToSection = function(section) {
      var defaultOptions, options;
      this.scrolling = true;
      defaultOptions = {
        onAfter: _.bind(this.afterScroll, this)
      };
      options = _.extend(defaultOptions, this.options.scrollToOptions);
      return $.scrollTo('#' + section, this.options.scrollTime, options);
    };

    SinglePageScrollingController.prototype.afterScroll = function() {
      return this.scrolling = false;
    };

    SinglePageScrollingController.prototype.appLoaded = function(viewName) {
      var instanceReady, targetSection;
      targetSection = this._fragmentToSection();
      try {
        instanceReady = targetSection.instance.ready;
      } catch (_error) {
        instanceReady = false;
      }
      if (!(this._allSectionsReady() || this.ready || instanceReady)) {
        return;
      }
      if (this._appLoaded) {
        return;
      }
      this.ready = true;
      this.navigate(Backbone.history.fragment);
      this._appLoaded = true;
      return $(window).on('scroll', (function(_this) {
        return function() {
          return _this.navigateOnScroll();
        };
      })(this));
    };

    SinglePageScrollingController.prototype.loadSection = function(section, name, sections) {
      var view;
      if (!_.has(section, 'view')) {
        this.sections[name].view = SinglePageScrollingView;
      }
      view = this.sections[name].instance = new section.view({
        notifications: this.notifications,
        pageName: name,
        currentResolution: this._getResolution().name,
        el: section.el
      });
      return view.render();
    };

    SinglePageScrollingController.prototype._allSectionsReady = function() {
      var sectionNotReady;
      sectionNotReady = _.find(this.sections, function(section) {
        if (_.isUndefined(section.instance)) {
          return true;
        }
        if (_.isUndefined(section.route)) {
          return;
        }
        if (!section.instance.ready) {
          return true;
        }
      });
      return _.isUndefined(sectionNotReady);
    };

    SinglePageScrollingController.prototype._isSectionReady = function(name) {
      try {
        return this.sections[name].instance.ready;
      } catch (_error) {
        return false;
      }
    };

    SinglePageScrollingController.prototype._resolutionChanged = function(e) {
      this._setResolution();
      try {
        if (this.previousResolution === this.currentResolution) {
          return;
        }
      } catch (_error) {
        return;
      }
      this._logMessage("Resolution changed: " + this.currentResolution);
      this.notify('resolutionChanged', {
        newSize: this.currentResolution,
        prevSize: this.previousResolution
      });
      return this.previousResolution = this.currentResolution;
    };

    SinglePageScrollingController.prototype._setResolution = function() {
      return this.currentResolution = this._getResolution().name;
    };

    SinglePageScrollingController.prototype._getResolution = function() {
      var currWidth;
      currWidth = window.outerWidth;
      return _.find(this.resolutionBreakPoints, function(res) {
        if ((res.min <= currWidth && currWidth <= res.max)) {
          return true;
        }
      });
    };

    SinglePageScrollingController.prototype._logMessage = function(message, trace) {
      var error;
      if (!this.options.debug) {
        return;
      }
      try {
        console.log(message);
        if (trace) {
          return console.trace();
        }
      } catch (_error) {
        error = _error;
      }
    };

    SinglePageScrollingController.prototype._fragmentToSection = function(fragment) {
      if (_.isUndefined(fragment)) {
        fragment = Backbone.history.fragment;
      }
      return _.find(this.sections, function(section, name) {
        var regex;
        if (_.isUndefined(section.route)) {
          return false;
        }
        regex = this._routeToRegExp(section.route);
        if (regex.test(fragment)) {
          return true;
        }
      }, this);
    };

    SinglePageScrollingController.prototype.notify = function() {
      var args;
      args = [].slice.call(arguments);
      args[0] = 'controller:' + args[0];
      return this.notifications.trigger.apply(this.notifications, args);
    };

    SinglePageScrollingController.prototype.navigateOnScroll = function(e) {
      var route, section;
      if (!this.options.navigateOnManualScroll) {
        return;
      }
      if (this.scrolling) {
        return;
      }
      section = _.max(this.sections, (function(_this) {
        return function(section) {
          return _this.inViewport(section.el);
        };
      })(this));
      if (section === this.currentSection) {
        return;
      }
      try {
        route = section.instance.getRoute();
      } catch (_error) {
        e = _error;
        route = section.route;
      }
      this.navigate(route, {
        scroll: false
      });
      return this.currentSection = section;
    };

    SinglePageScrollingController.prototype.updatePageMeta = function(route) {
      var pageMeta;
      if (_.isEmpty(route)) {
        route = '';
      }
      ({
        "else": route = ['/', _.trim(route, '/'), '/'].join('')
      });
      pageMeta = this.pageMetaCollection.findWhere({
        url: route
      });
      if (_.isUndefined(pageMeta)) {
        return;
      }
      $('title').text(pageMeta.get('title'));
      $('meta[name="description"]').text(pageMeta.get('description'));
      return $('title[name="keywords"]').text(pageMeta.get('keywords'));
    };

    SinglePageScrollingController.prototype.inViewport = function(el) {
      var elBounds;
      elBounds = $(el).get(0).getBoundingClientRect();
      if (elBounds.bottom <= 0 || elBounds.top >= window.innerHeight) {
        return 0;
      }
      if (elBounds.top >= 0 && elBounds.bottom <= window.innerHeight) {
        return $(el).height();
      }
      if (elBounds.top >= 0 && elBounds.bottom >= window.innerHeight) {
        return $(el).height() - (elBounds.bottom - window.innerHeight);
      }
      if (elBounds.bottom < window.innerHeight && elBounds.top < 0) {
        return $(el).height() - (elBounds.top * -1);
      }
    };

    return SinglePageScrollingController;

  })(Backbone.Router);

  module.exports = SinglePageScrollingController;

}).call(this);

//# sourceMappingURL=controller.js.map
