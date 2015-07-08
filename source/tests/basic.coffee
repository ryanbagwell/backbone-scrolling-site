
class Page extends ScrollingSite.View


class Controller extends ScrollingSite.Controller

    appRoot: 'backbone-scrolling-site/tests'

    sections:

        home:
            route: '/'
            el: $('#home')
            view: Page

        one:
            route: 'page-1/'
            el: $('#one')
            view: Page

        two:
            route: 'page-2/'
            el: $('#two')
            view: Page

        three:
            route: 'page-3/'
            el: $('#three')
            view: Page

        four:
            route: 'page-4/'
            el: $('#four')
            view: Page
        #
        # We're adding a fifth page in here to ensure that
        # if you define a route without a matching section, it will not
        # err out
        #
        five:
            route: 'page-5/'
            el: $('#five')
            view: Page

module.exports = Controller
