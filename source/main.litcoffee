The main entry point.

    define (require) ->

        {
            Controller: require './controller'
            View: require './view'
        }

