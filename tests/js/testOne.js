var TestOne =
/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;
/******/
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	var Controller, Page,
	  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	  hasProp = {}.hasOwnProperty;
	
	Page = (function(superClass) {
	  extend(Page, superClass);
	
	  function Page() {
	    return Page.__super__.constructor.apply(this, arguments);
	  }
	
	  return Page;
	
	})(ScrollingSite.View);
	
	Controller = (function(superClass) {
	  extend(Controller, superClass);
	
	  function Controller() {
	    return Controller.__super__.constructor.apply(this, arguments);
	  }
	
	  Controller.prototype.appRoot = 'backbone-scrolling-site/tests';
	
	  Controller.prototype.sections = {
	    home: {
	      route: '/',
	      el: $('#home'),
	      view: Page
	    },
	    one: {
	      route: 'page-1/',
	      el: $('#one'),
	      view: Page
	    },
	    two: {
	      route: 'page-2/',
	      el: $('#two'),
	      view: Page
	    },
	    three: {
	      route: 'page-3/',
	      el: $('#three'),
	      view: Page
	    },
	    four: {
	      route: 'page-4/',
	      el: $('#four'),
	      view: Page
	    },
	    five: {
	      route: 'page-5/',
	      el: $('#five'),
	      view: Page
	    }
	  };
	
	  return Controller;
	
	})(ScrollingSite.Controller);
	
	module.exports = Controller;


/***/ }
/******/ ]);
//# sourceMappingURL=testOne.js.map