The Base class contains common methods that are mixed in
to the contoller and view

It has some dependencies:

    _s = require 'underscore.string'

    module.exports =

Attempts to call the method 'onChangeFromPreviousSizeToNewSize'
to handle responsive events, i.e. onChangeFromLargeToSmall

      onResolutionChanged: (resolution) ->

        @currentResolution = resolution.newSize

        methodname = "onChangeFrom#{_s.capitalize(resolution.prevSize)}To#{_s.capitalize(resolution.newSize)}"

        try
            this[methodName]()
        return