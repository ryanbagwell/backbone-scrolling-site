A base view that provides some global event
notifications and commonly used utility functions.

This is an AMD module designed to be used with require.js. Therefore, it
relies on the following dependencies that we should define in our
require.js config.

First, declare the dependencies

    $ = require "jquery"
    _ = require "underscore"
    _.str = require 'underscore.string'
    _.mixin _.str.exports()
    Base = require './base'
    Backbone = require "backbone"

    module.exports = class SinglePageScrollingView extends Backbone.View

By default, the HTML tag will be a section

      tagName: 'section'

A placeholder for the global event disptatcher
object that should be passed in

      notifications: null

A placeholder property that is updated when
the view is notifified of a change in resolution

      currentResolution: null

Initially, the view isn't ready

      ready: false

Initialize the view.

      initialize: (options={}) ->
        @options = options

        @[name] = _.bind(method, @) for name, method of Base

        super(options)

Call 'afterRender()' when the rendered event is triggered

        @.on 'rendered', _.bind(@afterRender, @)

        try

Set the initial value of currentResolution

          @currentResolution = @options.currentResolution

Set the value of the event dispatcher

          @notifications = @options.notifications

Bind some event handlers to the appLoaded and resolutionChaged events
from the controller, as well as navigation events for this view

          @notifications.on
              "controller:appLoaded": @onAppLoaded
              "controller:resolutionChanged": @onResolutionChanged
          , @

        catch e
          console.warn "backbone-scrolling-site: Couldn't bind events to view named #{@options.pageName}"

Render the HTML, and triggers the "rendered" event

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


Dispatches a namespaced event notification to the controller.

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
