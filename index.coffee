js2coffee       = require 'js2coffee'
gutil           = require 'gulp-util'
path            = require 'path'
PluginError     = gutil.PluginError
{Transform} = require 'stream'

module.exports = ->
  class JavascriptToCoffeeScript extends Transform
    constructor: ->
      super objectMode: true

    _transform: (file, enc, next) =>
      if file.isNull()
        @push file
        return next()

      return next(new PluginError('gulp-js2coffee', 'Streaming not supported')) if file.isStream()

      dest = gutil.replaceExtension file.path, '.coffee'
      jsCode = file.contents.toString 'utf8'
      try
        {code} = js2coffee.build jsCode
        file.contents = new Buffer code
        file.path = dest
      catch {description, error, start}
        error = new Error "#{file.path}: #{description}. line: #{start.line}, column: #{start.column}"
        return next error

      @push file
      next()

  new JavascriptToCoffeeScript()
