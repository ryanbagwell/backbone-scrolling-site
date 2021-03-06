A base view that provides some global event
notifications and commonly used utility functions.

This is an AMD module designed to be used with require.js. Therefore, it
relies on the following dependencies that we should define in our
require.js config.

First, declare the dependencies

    $ = require "jquery"
    _ = require "underscore"
    Backbone = require "backbone"
    Q = require 'q'
    mixins = require './base'


    class SinglePageScrollingView extends Backbone.View

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

Some methods to assist with mixins

      @extend: (obj) ->
        for key, value of obj
          @[key] = value

        obj.extended?.apply(@)
        this

      @include: (obj) ->
        for key, value of obj
          # Assign properties to the prototype
          @::[key] = value

        obj.included?.apply(@)
        this

Initialize the view.

      initialize: (options={}) ->
        @options = options

        super(options)

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

        Q.fcall( =>
          deferred = Q.defer()
          @render(deferred.resolve)
          deferred
        ).then( =>
          deferred = Q.defer()
          @afterRender(deferred.resolve)
          deferred
        ).then( =>
          deferred = Q.defer()
          @afterReady(deferred.resolve)
          deferred
        ).then( =>
          deferred = Q.defer()
          @cleanup(deferred.resolve)
          deferred
        )

Render the HTML, and triggers the "rendered" event

      render: (done) ->
        @rendered = true
        done()


Called when the HTML has been redered,
and when the section is ready to be displayed

      afterRender: (done) ->
        @ready = true
        @sendNotification "sectionReady", @options.pageName
        done()

Called when the section is ready to be displayed

      afterReady: (done) ->
        done()

Removes event handlers that are only used in the initialization process

      cleanup: (done) ->
        @off "rendered"
        @off "sectionReady"
        done()

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

Specifies the element that the controller will scroll the page to
when navigate is called.

      getScrollToElement: ->
        @$el

Parses a requested url and returns its parts

      _parseRoute: (route) ->
        return []    if route is "" or route is "/"
        try
            return route.replace(/^\/|\/$/g, "").split("/")
        catch error
            return []
        return

    class MixedIn extends SinglePageScrollingView
      @include mixins

    module.exports = MixedIn
