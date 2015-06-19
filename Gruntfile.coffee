path = require 'path'

module.exports = (grunt) ->
  _ = grunt.util._


  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

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

    webpack:
      options:
        cache: true
        devtool: 'sourcemap'
        entry:
          "backbone-scrolling-site":"main"
        output:
          path: "dist/"
          filename: "[name].js"
          chunkFilename: "[id].js"
          libraryTarget: "commonjs2"
        resolve:
          extensions: ['.coffee', '.litcoffee', '.js', '']
          modulesDirectories: [
            'node_modules'
            'source'
          ]
        module:
          loaders: [
            {test: /jquery\.js$/, loader: 'expose?$!expose?jQuery'}
            {test: /underscore\.js$/, loader: 'expose?_'}
            {test: /backbone\.js$/, loader: 'expose?Backbone'}
            {test: /\.coffee$/, loaders: ['coffee-loader']}
            {test: /\.litcoffee$/, loaders: ['coffee-loader?literate']}
          ]
        stats:
          colors: true
          modules: true
          reasons: true
        failOnError: false

      production:
        watch: false
        keepalive: false

      dev:
        watch: true
        keepalive: true

    docco:
      src: ['source/**/*.litcoffee']
      options:
        output: 'docs/'

    bump:
      options:
        pushTo: 'origin'
        files: ['package.json', 'bower.json']
        syncVersions: true
        commitFiles: ['dist/*', 'docs/*', 'source/*', '.gitignore', './*.{json,md,coffee}']

    #Load grunt plugins
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-bump'
    grunt.loadNpmTasks 'grunt-docco'
    grunt.loadNpmTasks 'grunt-webpack'

    # Define tasks.
    grunt.registerTask 'build', ['webpack:production', 'docco']
    grunt.registerTask 'default', ['build']