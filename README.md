# Backbone Scrolling Site

A Backbonejs-based framework for creating single-page scrolling sites.

Each user-defined route (or url) corresponds to a particular section
on the site, which can also be thought of as a "page."

If necessary, a Backbone View can be created for each section, allowing interaction
with the controller and the initialization process.


## SinglePageScrollingController

The SinglePageScrollingController handles site-wide operations and functions, including:

* navigation events
* initializing and rendering views
* updating SEO meta data (i.e. title, keywords and description)
* notifying views of responsive break points
* event notifications with views

## SinglePageScrollingView

The SinglePageScrollingView initializes javascript for each section. The initialization process provides several "hooks" that can be used to intervene in the loading process.