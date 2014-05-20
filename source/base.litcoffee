The Base class contains common methods that are mixed in
to the contoller and view

It has a number of require.js dependencies.

    define (require) ->

        baseMethods =

Attempts to call the method 'onChangeFromPreviousSizeToNewSize'
to handle responsive events, i.e. onChangeFromLargeToSmall

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