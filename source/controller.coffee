define (require) ->
    $ = require 'jquery'
    _ = require 'underscore'
    _.str = require 'underscore-string'
    _.mixin _.str.exports()
    Backbone = require 'backbone'
    require 'jquery-scrollto'


    class SinglePageScrollingController extends Backbone.Router

        #
        # An array of sections
        # Each should be an object consisting of:
        #   viewName:
        #       route: 'path-to-route' (optional)
        #       el: $('div') #the views element
        #
        sections: {}

        #
        # Load each section asynchronously.
        # Set to false to load each section in order
        #
        loadAync: true


        #
        # A dictionary of responsive
        # break points that define when
        # notifications are sent
        #
        resolutionBreakPoints: [
            name: 'large-devices'
            min: 1200
            max: 100000000
        ,
            name: 'medium-devices'
            min: 992
            max: 1199
        ,
            name: 'small-devices'
            min: 768
            max: 991
        ,
            name: 'extra-small-devices'
            min: 0
            max: 767
        ]

        #
        # A dictionary that will supply
        # our page meta and SEO data
        #
        pageMeta: []

        currentResolution: 0

        previousResolution: 0

        notifications: null

        ready: false

        scrolling: false

        defaultOptions:
            debug: false


        # initialize: ->
        #     super
        #     console.log @navigate

        initialize: (options) ->
            @options = options

            super(options)

            _.bind(@[name], @) for name of @ when _.isFunction(@[name])


            #
            # Dynamically create our routes
            #
            _.each @sections, (section, name) ->
                return if _.isUndefined section.route

                @route section.route, -> null

            , @

            #
            # Set our default options
            #
            this.options = _.extend(this.defaultOptions, options)

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
            @pageMetaCollection = new Backbone.Collection(@pageMeta)


            #
            # Listen for the sectionReady event
            # from our child views
            #
            this.notifications.on 'view:sectionReady', @appLoaded

            #
            # Listen for the navigate event
            #
            @notifications.on 'view:navigate', @navigate

            #
            # Listen for reinitializing a view
            #
            this.notifications.on 'view:reinitializeSection', @reinitializeSection


            #
            # dispatch the windowResized event globally
            # to notify all view the window has been resized
            #
            $(window).on('resize', _.bind(_.debounce(->
                @notify 'windowResized'
            , 500), this))


            #
            # trigger the window resize event when the orientation
            # is changed
            #
            $(window).on 'orientationchange', ->
                $(window).trigger 'resize'


            #send a notification of new breakpoints
            $(window).on 'resize', _.bind(@_resolutionChanged, this)

            #
            # Dynamically create a route function for each
            # specified section
            #
            _.each @sections, (params, name, sections) ->
                @route params.route, name, @navigate if _.has params, 'route'
            , @

            #
            # Trigger a navigation event on all
            # local urls
            @_bindNavigate()

            #
            # Load our child views
            #
            # _.each @sections, this.loadSection




        #
        # Receives the navigate event from the
        # global event dispatcher
        #
        navigate: (route, options) ->

            return if not @ready

            options = _.extend {trigger:true}, options

            super _.ltrim(route, '/'), options

            @updatePageMeta route

            return unless options.trigger

            section = @_fragmentToSection()

            id = section.instance.options.pageName

            @scrollToSection id

            @notify 'header:navigate', id
            @notify id+':navigate', route



        #
        # Scrolls the page to the given section
        #
        scrollToSection: (section) ->

            @scrolling = true

            $.scrollTo '#'+section, 500,
                offset: -50
                onAfter: _.bind ->
                  @scrolling = false
                , this


        #
        # Called after all pages are loaded
        #
        appLoaded: (viewName) ->

            console.log @

            targetSection = @_fragmentToSection()

            try
                instanceReady = targetSection.instance.ready
            catch
                instanceReady = false

            return unless (@_allSectionsReady() or @ready or instanceReady)

            return if @_appLoaded

            @ready = true

            #
            # Start backbone.history
            #
            Backbone.history.start
                pushState: true

            @navigate Backbone.history.fragment

            window.loading.on 'removed', ->
                @notify 'appLoaded'
                $(window).on 'scroll', @updateNavigation
            , @

            window.loading.remove()

            @_appLoaded = true


        #
        # Instantiates the given section view.
        # If the view doesn't have any dependencies,
        # calls the load() method
        #
        loadSection: (section, name, sections) ->

            view = @sections[name].instance = new section.view
                notifications: @notifications
                pageName: name
                currentResolution: @_getResolution().name
                el: section.el

            view.render()



        #
        # Checks if all of the sections have reached the
        # 'ready' phase of the loading process
        #
        _allSectionsReady: ->

            sectionNotReady = _.find this.sections, (section) ->
                return true if _.isUndefined section.instance
                return if _.isUndefined section.route
                return true if not section.instance.ready

            return _.isUndefined sectionNotReady

        #
        # Returns true if the given section is ready. Otherwise, false
        #
        _isSectionReady: (name) ->

            try
                return @sections[name].instance.ready
            catch
                return false


        #
        # Watches the width of the browser,
        # and sends a notification if the width
        # has crossed one of the thresholds
        # listed in resolutionBreakPoints object
        #
        _resolutionChanged: (e) ->
            @_setResolution()

            try
                return if @previousResolution.name is @currentResolution.name
            catch
                return

            @_logMessage "Resolution changed: " + @currentResolution.name

            @notify 'resolutionChanged',
                newSize: this.currentResolution.name
                prevSize: this.previousResolution.name

            @previousResolution = @currentResolution


        #
        # Sets the current browser width based on the
        # resolution breakpoints object
        #
        _setResolution: ->
            @currentResolution = @_getResolution()


        #
        # Retrieves the name of the current resolution
        #
        _getResolution: ->
            currWidth = $(window).width()

            return _.find @resolutionBreakPoints, (res) ->
                return true if (currWidth > res.min and currWidth <= res.max)


        _logMessage: (message, trace) ->

            return if not this.options.debug

            try
                console.log(message);
                console.trace() if trace
            catch error

        #
        # Checks to see if the current URL fragment corresponds to
        # one of our sections, and returns the section object
        #
        _fragmentToSection: ->

            _.find @sections, (section, name) ->
                return false if _.isUndefined section.route
                regex = @_routeToRegExp(section.route)
                return true if regex.test(Backbone.history.fragment)

            , @

        #
        # Dispatches a namespaced event notification
        #
        notify: ->

            args = [].slice.call(arguments)
            args[0] = 'controller:'+args[0]
            @notifications.trigger.apply @notifications, args

        #
        # Updates the navigation items
        #
        updateNavigation: (e) ->

            return if @scrolling

            sectionEl = _.filter $('section'), (el) ->
                return _.inViewport el

            sectionId = $(sectionEl).attr 'id'

            route = $('header li.'+sectionId+' a').attr 'href'

            @notify 'updateNav', sectionId

            @navigate route,
                trigger: false


        #
        # Updates the page meta data
        #
        updatePageMeta: (route) ->

            if _.isEmpty route
                route = ''
            else:
                route = ['/', _.trim(route, '/'), '/'].join('')

            pageMeta = this.pageMetaCollection.findWhere
                url: route

            return if _.isUndefined pageMeta

            $('title').text(pageMeta.get('page_title'))
            $('meta[name="description"]').text(pageMeta.get('page_description'))
            $('title[name="keywords"]').text(pageMeta.get('page_keywords'))


        #
        # Bind click handlers to local urls
        # to call the navigate event
        #
        _bindNavigate: ->
            $('a[href^="/"],a[href^="'+window.location.origin+'"]').not("[data-unbind]").on 'click', _.bind(@_handleNavClick, @)

        #
        #
        #
        _handleNavClick: (e) ->
            e.preventDefault()
            console.log @
            @navigate $(e.currentTarget).attr('href'), {trigger: true}






