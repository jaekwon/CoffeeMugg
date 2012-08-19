tests =
  'Literal text':
    template: ->
      @text 'Just text'
    expected: 'Just text'

  'Default DOCTYPE':
    template: ->
      @doctype()
    expected: '<!DOCTYPE html>'

  'DOCTYPE':
    template: ->
      @doctype 'xml'
    expected: '<?xml version="1.0" encoding="utf-8" ?>'

  'Custom tag':
    template: ->
      @tag 'custom'
    expected: '<custom></custom>'

  'Custom tag with attributes':
    template: ->
      @tag 'custom', foo: 'bar', ping: 'pong'
    expected: '<custom foo="bar" ping="pong"></custom>'

  'Custom tag with attributes and inner content':
    template: ->
      @tag 'custom', foo: 'bar', ping: 'pong', -> 'zag'
    expected: '<custom foo="bar" ping="pong">zag</custom>'

  'Self-closing tags':
    template: ->
      @img src: 'icon.png', alt: 'Icon'
    expected: '<img src="icon.png" alt="Icon" />'

  'Common tag':
    template: ->
      @p 'hi'
    expected: '<p>hi</p>'

  'Attributes':
    template: ->
      @a href: '/', title: 'Home'
    expected: '<a href="/" title="Home"></a>'

  'HereDocs':
    template: ->
      @script """
        $(document).ready(function(){
          alert('test');
        });
      """
    expected: "<script>$(document).ready(function(){\n  alert('test');\n});</script>"

  'Context vars':
    template: (p) ->
      @h1 p.foo
    expected: '<h1>bar</h1>'
    params: [{foo: 'bar'}]

  'Comments':
    template: ->
      @comment 'Comment'
    expected: '<!--Comment-->'

  'Escaping':
    template: ->
      @h1 @h("<script>alert('\"pwned\" by c&a &copy;')</script>")
    expected: "<h1>&lt;script&gt;alert('&quot;pwned&quot; by c&amp;a &amp;copy;')&lt;/script&gt;</h1>"

  'Autoescaping':
    template: ->
      @h1 "<script>alert('\"pwned\" by c&a &copy;')</script>"
    expected: "<h1>&lt;script&gt;alert('&quot;pwned&quot; by c&amp;a &amp;copy;')&lt;/script&gt;</h1>"
    options: {autoescape: yes}

  'ID/class shortcut (combo)':
    template: ->
      @div '#myid.myclass1.myclass2', 'foo'
    expected: '<div id="myid" class="myclass1 myclass2">foo</div>'

  'ID/class shortcut (ID only)':
    template: ->
      @div '#myid', 'foo'
    expected: '<div id="myid">foo</div>'

  'ID/class shortcut (one class only)':
    template: ->
      @div '.myclass', 'foo'
    expected: '<div class="myclass">foo</div>'

  'ID/class shortcut (multiple classes)':
    template: ->
      @div '.myclass.myclass2.myclass3', 'foo'
    expected: '<div class="myclass myclass2 myclass3">foo</div>'

  'ID/class shortcut (no string contents)':
    template: ->
      @img '#myid.myclass', src: '/pic.png'
    expected: '<img id="myid" class="myclass" src="/pic.png" />'
      
  'Attribute values':
    template: ->
      @br vrai: yes, faux: no, undef: @foo, nil: null, str: 'str', num: 42, arr: [1, 2, 3], obj: {foo: 'bar'}, func: ->,
    expected: '<br vrai="vrai" str="str" num="42" arr="1,2,3" obj="[object Object]" func="function () {}" />'
    
  'IE conditionals':
    template: ->
      @html ->
        @head ->
          @title 'test'
          @ie 'gte IE8', ->
            @link href: 'ie.css', rel: 'stylesheet'

    expected: '''
      <html>
        <head>
          <title>test</title>
          <!--[if gte IE8]>
            <link href="ie.css" rel="stylesheet" />
          <![endif]-->
        </head>
      </html>
    '''
    options: {format: yes}

  'CoffeeScript function':
    template: ->
      @coffeescript ->
        alert 'hi'
    expected: '''<script>var __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child;},__bind = function(fn, me){ return function(){ return fn.apply(me, arguments); };},__indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1;},__hasProp = {}.hasOwnProperty,__slice = [].slice;(function () {\n          return alert('hi');\n        }).call(this);</script>'''
    # This gets retained somehow?
    options: {format: no}

  'CoffeeScript string':
    template: ->
      @coffeescript "alert 'hi'"
    expected: '''<script type="text/coffeescript">alert 'hi'</script>'''

  'CoffeeScript object':
    template: ->
      @coffeescript src: 'script.coffee'
    expected: '''<script src="script.coffee" type="text/coffeescript"></script>'''

cm = require './src/coffeemugg'

@run = ->
  {print} = require 'sys'
  colors = {red: "\x1b[31m", redder: "\x1b[91m", green: "\x1b[32m", normal: "\x1b[0m"}
  printc = (color, str) -> print colors[color] + str + colors.normal

  [total, passed, failed, errors] = [0, [], [], []]

  for name, test of tests
    total++
    try
      test.original_params = JSON.stringify test.params

      if test.run
        test.run()
      else
        test.result = cm.render(test.template, test.options, (test.params || [])...)
        test.success = test.result is test.expected
        
      if test.success
        passed.push name
        print "[Passed] #{name}\n"
      else
        failed.push name
        printc 'red', "[Failed] #{name}\n"
    catch ex
      test.result = ex
      errors.push name
      printc 'redder', "[Error]  #{name}\n"

  print "\n#{total} tests, #{passed.length} passed, #{failed.length} failed, #{errors.length} errors\n\n"
  
  if failed.length > 0
    printc 'red', "FAILED:\n\n"

    for name in failed
      t = tests[name]
      print "- #{name}:\n"
      print t.template + "\n"
      print t.original_params + "\n" if t.params
      printc 'green', "["+t.expected + "]\n"
      printc 'red', "["+t.result + "]\n\n"

  if errors.length > 0
    printc 'redder', "ERRORS:\n\n"

    for name in errors
      t = tests[name]
      print "- #{name}:\n"
      print t.template + "\n"
      printc 'green', t.expected + "\n"
      printc 'redder', t.result.stack + "\n\n"
