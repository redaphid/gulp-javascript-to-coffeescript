JavascriptToCoffeeScript  = require '../'
js2coffee                 = require 'js2coffee'
gutil                     = require 'gulp-util'
fs                        = require 'fs'
path                      = require 'path'
stream                    = require 'stream'

createFile = (filepath, contents) ->
  base = path.dirname(filepath)
  new (gutil.File)(
    path: filepath
    base: base
    cwd: path.dirname(base)
    contents: contents)

describe 'gulp-javascript-to-coffeescript', ->
  beforeEach ->
    @sut = JavascriptToCoffeeScript
  describe 'JavascriptToCoffeeScript()', ->
    before ->
      @testData = (expected, newPath, done) =>
        newPaths = [ newPath ]
        expected = [ expected ]
        (newFile) =>
          @expected = expected.shift()
          newPath = newPaths.shift()
          expect(newFile).to.exist
          expect(newFile.path).to.exist
          expect(newFile.relative).to.exist
          expect(newFile.contents).to.exist

          expect(newFile.path).to.equal newPath
          expect(newFile.relative).to.equal path.basename(newPath)
          expect(String(newFile.contents)).to.equal @expected
          done() if done and !expected.length

    it 'should concat two files', (done) ->
      filepath = '/home/redaphid/test/file.js'
      contents = new Buffer('function bizarro (){ alert("This is backwards-land!!") }')
      expected = js2coffee.build(String contents).code
      @sut()
        .on 'error', done
        .on 'data', @testData(expected, path.normalize('/home/redaphid/test/file.coffee'), done)
        .write createFile(filepath, contents)

    it 'should emit errors correctly', (done) ->
      filepath = '/home/redaphid/test/file.js'
      contents = new Buffer('if a()\u000d\n  then huh')

      @sut()
        .on 'error', (err) =>
          expect(err.message).to.equal '/home/redaphid/test/file.js: Unexpected identifier. line: 1, column: 3'
          done()
        .on 'data', (newFile) => throw new Error 'no file should have been emitted!'
        .write createFile(filepath, contents)

    it 'should compile a file', (done) ->
      filepath = 'test/fixtures/dumb-function.js'
      contents = new Buffer(fs.readFileSync filepath )
      expected = js2coffee.build(String contents).code
      @sut()
        .on('error', done)
        .on('data', @testData(expected, path.normalize('test/fixtures/dumb-function.coffee'), done))
        .write createFile(filepath, contents)
