The SinglePageScrollingController class.

It has a number of require.js dependencies.

    define (require) ->
        $ = require 'jquery'
        _ = require 'underscore'
        _.str = require 'underscore.string'
        _.mixin _.str.exports()
        Backbone = require 'backbone'
        Base = require './base'
        require 'jquery.scrollTo'
        SinglePageScrollingView = require './view'

        class SinglePageScrollingController extends Backbone.Router

The sections object represents all sections/pages of the site. Each item should
consist key=>value pairs. The key will become the name of the view (i.e. 'home'). The value should be an object consisting of the following parameters:

route: the route that will trigger a scrolling navigation event to that section
el: the html element that will attach to the view
view: an uninitialized view that is a subclasee of SinglePageScrollingView

            sections: {}

            loadAync: true

A dictionary of responsive break points that child view will be notified of.

            resolutionBreakPoints: [
                name: 'large'
                min: 1200
                max: 100000000
            ,
                name: 'medium'
                min: 992
                max: 1199
            ,
                name: 'small'
                min: 768
                max: 991
            ,
                name: 'extraSmall'
                min: 0
                max: 767
            ]

A placeholder for the current resolution

            currentResolution: 0

A placeholder for the previous resolution

            previousResolution: 0

A placeholder for our notifications object

            notifications: null

The site is not ready.

            ready: false


The site is not scrolling.

            scrolling: false

How many pixels of a section should be visible in the viewport
for it to be considered the active section?

            navigationOffset: 0

Some default options that will be merged with any user-defined options.

            defaultOptions:

Setting debug to true will print debug information to the console.
                debug: false

The time in milliseconds it takes to scroll to a section.

                scrollTime: 500

Pass in options for the scrollTo jquery plugin

                scrollToOptions: {}

Enable/Disable navigation on manual scroll

                navigateOnManualScroll: true

Initialize the controller.

            initialize: (options) ->

Merge our options with the defaultOptions

                @options = _.extend(@defaultOptions, options)

                @[name] = _.bind(method, @) for name, method of Base

                super(options)

                #
                # Dynamically create our routes
                #
                _.each @sections, (section, name) ->
                    return if _.isUndefined section.route
                    @route section.route, -> null
                , @

                #
                # A global event dispatcher
                #
                @notifications = _.clone Backbone.Events

                #
                # Set the initial browser resolution
                #
                @_resolutionChanged()

                #
                # Turn our page meta json
                # into a backbone collection
                #
                @pageMetaCollection = new Backbone.Collection(@options.pageMeta)

Call the onResolutionChanged method upon notification

                @notifications.on 'controller:resolutionChanged', @onResolutionChanged, @

Listen for "sectionReady" event notifcations that come from child views.

                this.notifications.on 'view:sectionReady', @appLoaded, @

Listen for "navigate" notifications that originate from child views.

                @notifications.on 'view:navigate', @navigate, @


                #
                # dispatch the windowResized event globally
                # to notify all view the window has been resized
                #
                $(window).on('resize', _.bind(_.debounce(->
                    @notify 'windowResized'
                , 500), this))


Trigger the window resize event when the orientation
is changed

                $(window).on 'orientationchange', ->
                    $(window).trigger 'resize'

When the window is resized, send a notification to child views if
a responsive breakpoint threshold is crossed

                $(window).on 'resize', _.bind(@_resolutionChanged, this)


Dynamically create a route function for each specified section

                _.each @sections, (params, name, sections) ->
                    @route params.route, name, @navigate if _.has params, 'route'
                , @

Start Backbone.history

                Backbone.history.start
                    pushState: true
                    silent: true

Bind click handlers to all local 'a' tags in order to
trigger our navigate function. A tags with an attribute of 'data-unbind'
will be ignored.

                $('body').on 'click',
                    'a[href^="/"]:not([data-nobind]), body a[href^="'+window.location.origin+'"]:not([data-nobind])',
                    (e) =>
                        @navigate $(e.currentTarget).attr('href')
                        false

Initialize any section views.

                _.each @sections, @loadSection, @

The navigate function is bound to all clicks on local urls.

            navigate: (route, options) ->

                return if not @ready

                options = _.extend
                    trigger: false
                    scroll: true
                , options

                super _.ltrim(route, '/'), options

                @updatePageMeta route

                section = @_fragmentToSection(_.ltrim(route, '/'))

                @currentSection = section

                id = section.instance.options.pageName

                @scrollToSection(id) unless options.scroll is false

                @notify id+':navigate', route


Scrolls the page to the target section.

            scrollToSection: (section) ->

                @scrolling = true

                defaultOptions =
                    onAfter: _.bind @afterScroll, @

                options = _.extend defaultOptions, @options.scrollToOptions

                $.scrollTo '#'+section, @options.scrollTime, options


A method to call after the page has stopped scrolling.

            afterScroll: ->
                @scrolling = false

Each time a view is ready, it triggers a call to the appLoaded method,
which checks to see if all views are 'ready'.

            appLoaded: (viewName) ->

                targetSection = @_fragmentToSection()

                try
                    instanceReady = targetSection.instance.ready
                catch
                    instanceReady = false

                return unless (@_allSectionsReady() or @ready or instanceReady)

                return if @_appLoaded

                @ready = true

                @navigate Backbone.history.fragment

                @_appLoaded = true

Start listening for scroll events to call the navigation method

                $(window).on 'scroll', => @navigateOnScroll()

Load a section view function.

            loadSection: (section, name, sections) ->

Mock a view instance object if a view function wasn't specified.

                if not _.has(section, 'view')
                    @sections[name].view = SinglePageScrollingView

                view = @sections[name].instance = new section.view
                    notifications: @notifications
                    pageName: name
                    currentResolution: @_getResolution().name
                    el: section.el

                view.render()


Checks if all of the sections have reached the
'ready' phase of the loading process

            _allSectionsReady: ->

                sectionNotReady = _.find this.sections, (section) ->
                    return true if _.isUndefined section.instance
                    return if _.isUndefined section.route
                    return true if not section.instance.ready

                return _.isUndefined sectionNotReady


Returns true if the given section is ready. Otherwise, false

            _isSectionReady: (name) ->

                try
                    return @sections[name].instance.ready
                catch
                    return false



Watches the width of the browser,
and sends a notification if the width
has crossed one of the thresholds
listed in resolutionBreakPoints object

            _resolutionChanged: (e) ->
                @_setResolution()

                try
                    return if @previousResolution is @currentResolution
                catch
                    return

                @_logMessage "Resolution changed: " + @currentResolution

                @notify 'resolutionChanged',
                    newSize: @currentResolution
                    prevSize: @previousResolution

                @previousResolution = @currentResolution



Sets the current browser width based on the
resolution breakpoints object

            _setResolution: ->
                @currentResolution = @_getResolution().name



Retrieves the name of the current resolution

            _getResolution: ->
                currWidth = window.outerWidth

                return _.find @resolutionBreakPoints, (res) ->
                    return true if (res.min <= currWidth <= res.max)


            _logMessage: (message, trace) ->

                return if not this.options.debug

                try
                    console.log(message);
                    console.trace() if trace
                catch error


Checks to see if the current URL fragment corresponds to
one of our sections, and returns the section object

            _fragmentToSection: (fragment) ->

                if _.isUndefined fragment
                    fragment = Backbone.history.fragment

                _.find @sections, (section, name) ->
                    return false if _.isUndefined section.route
                    regex = @_routeToRegExp(section.route)
                    true if regex.test(fragment)
                , @


Dispatches a namespaced event notification

            notify: ->

                args = [].slice.call(arguments)
                args[0] = 'controller:'+args[0]
                @notifications.trigger.apply @notifications, args


Call the navigate method when the user is manually scrolling
and the most visible section has changed.

            navigateOnScroll: (e) ->

                return unless @options.navigateOnManualScroll

                return if @scrolling

                section = _.max @sections, (section) =>
                    @inViewport(section.el)

                return if section == @currentSection

                try
                    route = section.instance.getRoute()
                catch e
                    route = section.route

                @navigate route, scroll:false

                @currentSection = section

Updates the page meta data

            updatePageMeta: (route) ->

                if _.isEmpty route
                    route = ''
                else:
                    route = ['/', _.trim(route, '/'), '/'].join('')

                pageMeta = @pageMetaCollection.findWhere
                    url: route

                return if _.isUndefined pageMeta

                $('title').text(pageMeta.get('page_title'))
                $('meta[name="description"]').text(pageMeta.get('page_description'))
                $('title[name="keywords"]').text(pageMeta.get('page_keywords'))

Checks to see if the given element is substantially in the
viewport. Returns the height of visible portion of the element.

            inViewport: (el) ->

                elBounds = $(el).get(0).getBoundingClientRect()

                # the el is not visible
                return 0 if elBounds.bottom <= 0 or elBounds.top >= window.innerHeight

                #the el is entirely visible
                return $(el).height() if elBounds.top >= 0 and elBounds.bottom <= window.innerHeight

                #if the el's top is visible but not the bottom
                if elBounds.top >= 0 and elBounds.bottom >= window.innerHeight
                    return $(el).height() - (elBounds.bottom - window.innerHeight)

                #if the el's bottom is visible but not the top
                if elBounds.bottom < window.innerHeight and elBounds.top < 0
                    return $(el).height() - (elBounds.top * -1)
