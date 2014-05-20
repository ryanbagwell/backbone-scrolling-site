path = require 'path'

module.exports = (grunt) ->
  _ = grunt.util._


  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    coffee:
      options:
        sourceMap: true
      compile:
        files: [
          expand: true
          cwd: './source'
          src: ['**/*.{coffee,litcoffee}']
          dest: './dist'
          ext: '.js'
        ]

    watch:
      options:
        spawn: true
      coffee:
        cwd: './source/'
        files: ['**/*.{coffee,litcoffee}']
        tasks: ['coffee']


    uglify:
      options:
          mangle: true
      files: {
        expand: true
        flatten: false
        cwd: './dist'
        dest: './dist'
        src: [
          '**/*.js'
        ]
      }

    bump:
      files: ['package.json', 'bower.json']
      options:
        pushTo: 'origin'

    #Load grunt plugins
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-contrib-concat'
    grunt.loadNpmTasks 'grunt-bump'

    # Define tasks.
    grunt.registerTask 'build', ['coffee', 'concat']
    grunt.registerTask 'default', ['coffee']