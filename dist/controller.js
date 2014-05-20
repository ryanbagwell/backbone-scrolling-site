(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(function(require) {
    var $, Backbone, Base, SinglePageScrollingController, SinglePageScrollingView, _;
    $ = require('jquery');
    _ = require('underscore');
    _.str = require('underscore.string');
    _.mixin(_.str.exports());
    Backbone = require('backbone');
    Base = require('./base');
    require('jquery.scrollTo');
    SinglePageScrollingView = require('./view');
    return SinglePageScrollingController = (function(_super) {
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

      SinglePageScrollingController.prototype.pageMeta = [];

      SinglePageScrollingController.prototype.currentResolution = 0;

      SinglePageScrollingController.prototype.previousResolution = 0;

      SinglePageScrollingController.prototype.notifications = null;

      SinglePageScrollingController.prototype.ready = false;

      SinglePageScrollingController.prototype.scrolling = false;

      SinglePageScrollingController.prototype.defaultOptions = {
        scrollTime: 500,
        scrollToOptions: {}
      };

      SinglePageScrollingController.prototype.initialize = function(options) {
        var method, name;
        this.options = _.extend(this.defaultOptions, options);
        for (name in Base) {
          method = Base[name];
          this[name] = method;
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
        this.notifications = _.clone(Backbone.Events);
        this._resolutionChanged();
        this.pageMetaCollection = new Backbone.Collection(this.pageMeta);
        this.notifications.on('view:sectionReady', this.appLoaded, this);
        this.notifications.on('view:navigate', this.navigate);
        this.notifications.on('view:reinitializeSection', this.reinitializeSection);
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
        $('a[href^="/"], a[href^="' + window.location.origin + '"]').not("[data-nobind]").on('click', _.bind(function(e) {
          e.preventDefault();
          return this.navigate($(e.currentTarget).attr('href'));
        }, this));
        return _.each(this.sections, this.loadSection, this);
      };

      SinglePageScrollingController.prototype.navigate = function(route, options) {
        var id, section;
        if (!this.ready) {
          return;
        }
        options = _.extend({
          trigger: false
        }, options);
        SinglePageScrollingController.__super__.navigate.call(this, _.ltrim(route, '/'), options);
        this.updatePageMeta(route);
        section = this._fragmentToSection(_.ltrim(route, '/'));
        id = section.instance.options.pageName;
        this.scrollToSection(id);
        this.notify('header:navigate', id);
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
        return this._appLoaded = true;
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
          if (this.previousResolution.name === this.currentResolution.name) {
            return;
          }
        } catch (_error) {
          return;
        }
        this._logMessage("Resolution changed: " + this.currentResolution.name);
        this.notify('resolutionChanged', {
          newSize: this.currentResolution.name,
          prevSize: this.previousResolution.name
        });
        return this.previousResolution = this.currentResolution;
      };

      SinglePageScrollingController.prototype._setResolution = function() {
        return this.currentResolution = this._getResolution();
      };

      SinglePageScrollingController.prototype._getResolution = function() {
        var currWidth;
        currWidth = $(window).width();
        return _.find(this.resolutionBreakPoints, function(res) {
          if (currWidth > res.min && currWidth <= res.max) {
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

      SinglePageScrollingController.prototype.updateNavigation = function(e) {
        var route, sectionEl, sectionId;
        if (this.scrolling) {
          return;
        }
        sectionEl = _.filter($('section'), function(el) {
          return _.inViewport(el);
        });
        sectionId = $(sectionEl).attr('id');
        route = $('header li.' + sectionId + ' a').attr('href');
        this.notify('updateNav', sectionId);
        return this.navigate(route, {
          trigger: false
        });
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
        $('title').text(pageMeta.get('page_title'));
        $('meta[name="description"]').text(pageMeta.get('page_description'));
        return $('title[name="keywords"]').text(pageMeta.get('page_keywords'));
      };

      return SinglePageScrollingController;

    })(Backbone.Router);
  });

}).call(this);

//# sourceMappingURL=controller.js.map
