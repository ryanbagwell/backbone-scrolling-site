The Base class contains common methods that are mixed in
to the contoller and view

It has some dependencies:

    capitalize = require 'underscore.string/capitalize'

    methods =

Attempts to call the method 'onChangeFromPreviousSizeToNewSize'
to handle responsive events, i.e. onChangeFromLargeToSmall

      onResolutionChanged: (resolution) ->

        @currentResolution = resolution.newSize

        methodName = "onChangeFrom#{capitalize(resolution.prevSize)}To#{capitalize(resolution.newSize)}"

        try
            this[methodName]()
        return

Checks to see if the given element is substantially in the
viewport. Returns the height of visible portion of the element.

      inViewport: (el) ->

        return 0 unless $(el).length

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

        #the el is filling the entire window
        return $(el).height() if elBounds.top <= 0 and elBounds.bottom >= window.innerHeight

      makeRouteFunction: ->

        return ->
            [section, name, args...] = arguments
            if section.instance?
              section.instance.receiveNavigation.apply(section.instance, args)
            @_logMessage 'Route triggered'
            @notify "#{name}:navigate"

    module.exports = methods
