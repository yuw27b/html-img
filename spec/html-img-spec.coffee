{ join, resolve, extname } = require 'path'
{ readdirSync } = require 'fs'
{ WorkspaceView } = require 'atom'


describe "html-img", ->

  open = (file) ->
    atom.workspaceView = new WorkspaceView
    atom.project.setPath join __dirname, 'fixtures'
    atom.workspaceView.openSync file
    atom.workspaceView.attachToDom()
    editorView = atom.workspaceView.getActiveView()

    for lang in ['html', 'jade']
      languagePath = atom.packages.resolvePackagePath "language-#{lang}"
      grammarsPath = resolve languagePath, 'grammars'
      for grammarFile in readdirSync grammarsPath
        atom.syntax.loadGrammarSync resolve grammarsPath, grammarFile

    waitsForPromise -> atom.packages.activatePackage 'html-img'

    editorView

  assert = (editorView, command, expected, position = [0, 1]) ->
    editor = editorView.getEditor()
    runs ->
      editor.setCursorBufferPosition position
      editorView.trigger command
    waits 100
    runs ->
      expect(editor.getText()).toBe("#{expected}\n")
      editor.undo()

  describe "in HTML", ->

    it "recognizes tag range", ->
      editorView = open 'htdocs/html/tag-range.html'
      assert editorView, 'html-img:fill', '<img src="../images/example.png"><img src="../images/example.png">', [0, 0]
      for col in [1..32]
        assert editorView, 'html-img:fill', '<img src="../images/example.png" width="800" height="500"><img src="../images/example.png">', [0, col]
      assert editorView, 'html-img:fill', '<img src="../images/example.png"><img src="../images/example.png">', [0, 33]
      for col in [34..65]
        assert editorView, 'html-img:fill', '<img src="../images/example.png"><img src="../images/example.png" width="800" height="500">', [0, col]
      assert editorView, 'html-img:fill', '<img src="../images/example.png"><img src="../images/example.png">', [0, 66]

    it "recognizes spaced tag", ->
      editorView = open 'htdocs/html/tag-spaced.html'
      assert editorView, 'html-img:fill', '<img\n  alt = "foo"\n  src = "../images/example.png"\n  >', [0, 0]
      assert editorView, 'html-img:fill', '<img\n  alt = "foo"\n  src = "../images/example.png"\n  width="800" height="500">', [0, 1]
      assert editorView, 'html-img:fill', '<img\n  alt = "foo"\n  src = "../images/example.png"\n  width="800" height="500">', [1, 1]
      assert editorView, 'html-img:fill', '<img\n  alt = "foo"\n  src = "../images/example.png"\n  width="800" height="500">', [2, 1]
      assert editorView, 'html-img:fill', '<img\n  alt = "foo"\n  src = "../images/example.png"\n  width="800" height="500">', [3, 1]
      assert editorView, 'html-img:fill', '<img\n  alt = "foo"\n  src = "../images/example.png"\n  >', [4, 0]

    it "supports base-absolute", ->
      editorView = open 'htdocs/html/base-absolute.html'
      assert editorView, 'html-img:fill', '<img src="/images/example.png" width="800" height="500">'
      assert editorView, 'html-img:fill-half', '<img src="/images/example.png" width="400" height="250">'
      assert editorView, 'html-img:fill-width', '<img src="/images/example.png" width="800">'
      assert editorView, 'html-img:fill-width-half', '<img src="/images/example.png" width="400">'
      assert editorView, 'html-img:fill-height', '<img src="/images/example.png" height="500">'
      assert editorView, 'html-img:fill-height-half', '<img src="/images/example.png" height="250">'

    it "supports base-relative", ->
      editorView = open 'htdocs/html/base-relative.html'
      assert editorView, 'html-img:fill', '<img src="../images/example.png" width="800" height="500">'
      assert editorView, 'html-img:fill-half', '<img src="../images/example.png" width="400" height="250">'
      assert editorView, 'html-img:fill-width', '<img src="../images/example.png" width="800">'
      assert editorView, 'html-img:fill-width-half', '<img src="../images/example.png" width="400">'
      assert editorView, 'html-img:fill-height', '<img src="../images/example.png" height="500">'
      assert editorView, 'html-img:fill-height-half', '<img src="../images/example.png" height="250">'

    it "supports protocol-absolute", ->
      editorView = open 'htdocs/html/protocol-absolute.html'
      assert editorView, 'html-img:fill', '<img src="https://cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" width="800" height="500">'
      assert editorView, 'html-img:fill-half', '<img src="https://cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" width="400" height="250">'
      assert editorView, 'html-img:fill-width', '<img src="https://cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" width="800">'
      assert editorView, 'html-img:fill-width-half', '<img src="https://cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" width="400">'
      assert editorView, 'html-img:fill-height', '<img src="https://cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" height="500">'
      assert editorView, 'html-img:fill-height-half', '<img src="https://cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" height="250">'

    it "supports protocol-relative", ->
      editorView = open 'htdocs/html/protocol-relative.html'
      assert editorView, 'html-img:fill', '<img src="//cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" width="800" height="500">'
      assert editorView, 'html-img:fill-half', '<img src="//cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" width="400" height="250">'
      assert editorView, 'html-img:fill-width', '<img src="//cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" width="800">'
      assert editorView, 'html-img:fill-width-half', '<img src="//cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" width="400">'
      assert editorView, 'html-img:fill-height', '<img src="//cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" height="500">'
      assert editorView, 'html-img:fill-height-half', '<img src="//cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" height="250">'

  describe "in Jade", ->

    it "supports base-absolute", ->
      editorView = open 'htdocs/jade/base-absolute.jade'
      assert editorView, 'html-img:fill', 'img(src="/images/example.png", width="800", height="500")'
      assert editorView, 'html-img:fill-half', 'img(src="/images/example.png", width="400", height="250")'
      assert editorView, 'html-img:fill-width', 'img(src="/images/example.png", width="800")'
      assert editorView, 'html-img:fill-width-half', 'img(src="/images/example.png", width="400")'
      assert editorView, 'html-img:fill-height', 'img(src="/images/example.png", height="500")'
      assert editorView, 'html-img:fill-height-half', 'img(src="/images/example.png", height="250")'

    it "supports base-relative", ->
      editorView = open 'htdocs/jade/base-relative.jade'
      assert editorView, 'html-img:fill', 'img(src="../images/example.png", width="800", height="500")'
      assert editorView, 'html-img:fill-half', 'img(src="../images/example.png", width="400", height="250")'
      assert editorView, 'html-img:fill-width', 'img(src="../images/example.png", width="800")'
      assert editorView, 'html-img:fill-width-half', 'img(src="../images/example.png", width="400")'
      assert editorView, 'html-img:fill-height', 'img(src="../images/example.png", height="500")'
      assert editorView, 'html-img:fill-height-half', 'img(src="../images/example.png", height="250")'

    it "supports protocol-absolute", ->
      editorView = open 'htdocs/jade/protocol-absolute.jade'
      assert editorView, 'html-img:fill', 'img(src="https://cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png", width="800", height="500")'
      assert editorView, 'html-img:fill-half', 'img(src="https://cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png", width="400", height="250")'
      assert editorView, 'html-img:fill-width', 'img(src="https://cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png", width="800")'
      assert editorView, 'html-img:fill-width-half', 'img(src="https://cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png", width="400")'
      assert editorView, 'html-img:fill-height', 'img(src="https://cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png", height="500")'
      assert editorView, 'html-img:fill-height-half', 'img(src="https://cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png", height="250")'

    it "supports protocol-relative", ->
      editorView = open 'htdocs/jade/protocol-relative.jade'
      assert editorView, 'html-img:fill', 'img(src="//cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png", width="800", height="500")'
      assert editorView, 'html-img:fill-half', 'img(src="//cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png", width="400", height="250")'
      assert editorView, 'html-img:fill-width', 'img(src="//cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png", width="800")'
      assert editorView, 'html-img:fill-width-half', 'img(src="//cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png", width="400")'
      assert editorView, 'html-img:fill-height', 'img(src="//cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png", height="500")'
      assert editorView, 'html-img:fill-height-half', 'img(src="//cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png", height="250")'

  # describe "in EJS", ->
  #
  #   it "recognizes tag range", ->
  #     editorView = open 'htdocs/ejs/tag-range.ejs'
  #     assert editorView, 'html-img:fill', '<img src="../images/example.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>"><img src="../images/example.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>">', [0, 116]
  #
  #   it "supports base-absolute", ->
  #     editorView = open 'htdocs/ejs/base-absolute.ejs'
  #     assert editorView, 'html-img:fill', '<img src="/images/example.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" width="800" height="500">'
  #     assert editorView, 'html-img:fill-half', '<img src="/images/example.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" width="400" height="250">'
  #     assert editorView, 'html-img:fill-width', '<img src="/images/example.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" width="800">'
  #     assert editorView, 'html-img:fill-width-half', '<img src="/images/example.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" width="400">'
  #     assert editorView, 'html-img:fill-height', '<img src="/images/example.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" height="500">'
  #     assert editorView, 'html-img:fill-height-half', '<img src="/images/example.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" height="250">'
  #
  #   it "supports base-relative", ->
  #     editorView = open 'htdocs/ejs/base-relative.ejs'
  #     assert editorView, 'html-img:fill', '<img src="../images/example.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" width="800" height="500">'
  #     assert editorView, 'html-img:fill-half', '<img src="../images/example.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" width="400" height="250">'
  #     assert editorView, 'html-img:fill-width', '<img src="../images/example.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" width="800">'
  #     assert editorView, 'html-img:fill-width-half', '<img src="../images/example.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" width="400">'
  #     assert editorView, 'html-img:fill-height', '<img src="../images/example.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" height="500">'
  #     assert editorView, 'html-img:fill-height-half', '<img src="../images/example.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" height="250">'
  #
  #   it "supports protocol-absolute", ->
  #     editorView = open 'htdocs/ejs/protocol-absolute.ejs'
  #     assert editorView, 'html-img:fill', '<img src="https://cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" width="800" height="500">'
  #     assert editorView, 'html-img:fill-half', '<img src="https://cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" width="400" height="250">'
  #     assert editorView, 'html-img:fill-width', '<img src="https://cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" width="800">'
  #     assert editorView, 'html-img:fill-width-half', '<img src="https://cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" width="400">'
  #     assert editorView, 'html-img:fill-height', '<img src="https://cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" height="500">'
  #     assert editorView, 'html-img:fill-height-half', '<img src="https://cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" height="250">'
  #
  #   it "supports protocol-relative", ->
  #     editorView = open 'htdocs/ejs/protocol-relative.ejs'
  #     assert editorView, 'html-img:fill', '<img src="//cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" width="800" height="500">'
  #     assert editorView, 'html-img:fill-half', '<img src="//cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" width="400" height="250">'
  #     assert editorView, 'html-img:fill-width', '<img src="//cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" width="800">'
  #     assert editorView, 'html-img:fill-width-half', '<img src="//cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" width="400">'
  #     assert editorView, 'html-img:fill-height', '<img src="//cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" height="500">'
  #     assert editorView, 'html-img:fill-height-half', '<img src="//cloud.githubusercontent.com/assets/514164/3367904/47f2f0ce-fb6b-11e3-9b0e-8f836f031d85.png" alt="<% if (foo < bar && bar > baz) { %><%= bar %><% } else { %><%- baz %><% } %>" height="250">'
