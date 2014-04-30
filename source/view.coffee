#
# * A base view that provides some global event
# * notifications and commonly used
# * utility functions
#
define (require) ->
    $ = require "jquery"
    _ = require "underscore"
    Backbone = require "backbone"


    class SinglePageScrollingView extends Backbone.View

        #
        # A placeholder for the
        # global event disptacer object
        # that should be passed in
        #
        notifications: null


        #
        # A placeholder property that
        # is updated when the view is notifified
        # of a change in resolution
        #
        currentResolution: null


        initialize: (options) ->
            @options = options
            super(options)


            try
                @currentResolution = @options.currentResolution
                @notifications = @options.notifications
                @notifications.on "controller:appLoaded", @onAppLoaded
                @notifications.on "controller:resolutionChanged", @onResolutionChanged
            catch

            if _.has(@options, 'pageName')
                eventName = ['controller', @options.pageName, 'navigate'].join(':')
                @notifications.on eventName, @receiveNavigation

        #
        # Renders the HTML
        #
        render: ->
            @rendered = true
            @trigger "rendered"


        #
        # Called when the HTML has been redered,
        # and when the section is ready to be displayed
        #
        afterRender: ->
            @sendNotification "sectionReady", @options.pageName
            @_setLocalUrlNavigate()
            @afterReady()


        #
        # Called when the section is ready to be displayed
        #
        afterReady: ->
            @cleanup()


        #
        #  Removes initialization event handlers
        #
        cleanup: ->
            @off "rendered"
            @off "sectionReady"


        #
        # Called when the appLoaded event is received
        #
        onAppLoaded: -> null


        #
        # Attempts to call the method
        # 'onChangeFrom<previousSize>To<newSize>'
        #
        onResolutionChanged: (resolution) ->

            @currentResolution = resolution.newSize

            methodName = [
                "onChangeFrom"
                Utilities.capitalize(resolution.prevSize)
                "To"
                Utilities.capitalize(resolution.newSize)
            ].join("")

            try
                this[methodName]()
            return


        #
        # Dispatches a namespaced event notification
        #
        sendNotification: ->

            args = [].slice.call(arguments)
            args[0] = 'view:'+args[0]
            @notifications.trigger.apply @notifications, args


        #
        # Sends the navigate event to the global notifier
        #
        sendNavigation: (route) ->
            @sendNotification 'navigate', route



        #
        # Receives the global navigation event
        #
        receiveNavigation: (route) ->
            @currentRoute = route

        #
        # Parses a requested url and returns its parts
        #
        _parseRoute: (route) ->
            return []    if route is "" or route is "/"
            try
                return route.replace(/^\/|\/$/g, "").split("/")
            catch error
                return []
            return


        #
        # Bind all click events on anchor
        # tags with local urls to call the
        # sendNavigation method on the given
        # contextObj. If not provided, contextObj
        # is set to "this".
        #
        _setLocalUrlNavigate: (contextObj) ->
            contextObj = this if _.isUndefined(contextObj)
            @$el.find("a[href^=\"/\"]").not('[trigger-exclude]').on "click", _.bind((e) ->
                e.preventDefault()
                e.stopPropagation()
                @sendNavigation $(e.currentTarget).attr("href")
                return
            , contextObj)
            return

