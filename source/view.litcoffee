A base view that provides some global event
notifications and commonly used utility functions

    define (require) ->
        $ = require "jquery"
        _ = require "underscore"
        _.str = require 'underscore.string'
        _.mixin _.str.exports()
        Backbone = require "backbone"

        class SinglePageScrollingView extends Backbone.View

A placeholder for the global event disptatcher
object that should be passed in

            notifications: null


A placeholder property that is updated when
the view is notifified of a change in resolution

            currentResolution: null

Initially, the view isn't ready

            ready: false

Initialize the view.

            initialize: (options) ->
                @options = options
                super(options)

                @.on 'rendered', _.bind(@afterRender, @)

                try
                    @currentResolution = @options.currentResolution
                    @notifications = @options.notifications
                    @notifications.on "controller:appLoaded", @onAppLoaded
                    @notifications.on "controller:resolutionChanged", @onResolutionChanged
                catch

                if _.has(@options, 'pageName')
                    eventName = ['controller', @options.pageName, 'navigate'].join(':')
                    @notifications.on eventName, @receiveNavigation

Renders the HTML

            render: ->
                @rendered = true
                @trigger "rendered"


Called when the HTML has been redered,
and when the section is ready to be displayed

            afterRender: ->
                @ready = true
                @sendNotification "sectionReady", @options.pageName
                @afterReady()

Called when the section is ready to be displayed

            afterReady: ->
                @cleanup()

Removes event handlers that are only used in the initialization process

            cleanup: ->
                @off "rendered"
                @off "sectionReady"

Called when the appLoaded event is received.

            onAppLoaded: -> null

Attempts to call the method 'onChangeFrom<previousSize>To<newSize>'
to handle responsive events

            onResolutionChanged: (resolution) ->

                @currentResolution = resolution.newSize

                methodName = _.join '',
                    'onChangeFrom',
                    _.str.capitalize(resolution.prevSize),
                    'To',
                    _.str.capitalize(resolution.newSize)

                try
                    this[methodName]()
                return

Dispatches a namespaced event notification.

            sendNotification: ->
                args = [].slice.call(arguments)
                args[0] = 'view:'+args[0]
                @notifications.trigger.apply @notifications, args

Sends the navigate event to the global notifier.

            sendNavigation: (route) ->
                @sendNotification 'navigate', route


Receives the global navigation event.

            receiveNavigation: (route) ->
                @currentRoute = route


Parses a requested url and returns its parts

            _parseRoute: (route) ->
                return []    if route is "" or route is "/"
                try
                    return route.replace(/^\/|\/$/g, "").split("/")
                catch error
                    return []
                return


