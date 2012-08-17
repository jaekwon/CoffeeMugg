if window?
  coffeemugg = window.CoffeeMug = {}
  coffee = if CoffeeScript? then CoffeeScript else null
  logger = {
    debug: (msg) -> console.log "debug: #{msg}"
    info:  (msg) -> console.log "info: #{msg}"
    warn:  (msg) -> console.log "warn: #{msg}"
    error: (msg) -> console.log "error: #{msg}"
  }
else
  coffeemugg = exports
  logger = require('nogg').logger('coffeemugg')
  coffee = require 'coffee-script'

coffeemugg.version = '0.0.2'

# Values available to the `doctype` function inside a template.
# Ex.: `doctype 'strict'`
coffeemugg.doctypes =
  'default': '<!DOCTYPE html>'
  '5': '<!DOCTYPE html>'
  'xml': '<?xml version="1.0" encoding="utf-8" ?>'
  'transitional': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
  'strict': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
  'frameset': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">'
  '1.1': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">',
  'basic': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">'
  'mobile': '<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">'
  'ce': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "ce-html-1.0-transitional.dtd">'

# CoffeeScript-generated JavaScript may contain anyone of these; but when we
# take a function to string form to manipulate it, and then recreate it through
# the `Function()` constructor, it loses access to its parent scope and
# consequently to any helpers it might need. So we need to reintroduce these
# inside any "rewritten" function.
# From coffee-script/lib/coffee-script/nodes.js under UTILITIES
coffeescript_helpers = """
  var __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
  __hasProp = {}.hasOwnProperty,
  __slice = [].slice;
""".replace /\n/g, ''

# Private HTML element reference.
# Please mind the gap (1 space at the beginning of each subsequent line).
elements =
  # Valid HTML 5 elements requiring a closing tag.
  # Note: the `var` element is out for obvious reasons, please use `tag 'var'`.
  regular: 'a abbr address article aside audio b bdi bdo blockquote body button
 canvas caption cite code colgroup datalist dd del details dfn div dl dt em
 fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hgroup
 html i iframe ins kbd label legend li map mark menu meter nav noscript object
 ol optgroup option output p pre progress q rp rt ruby s samp script section
 select small span strong style sub summary sup table tbody td textarea tfoot
 th thead time title tr u ul video'

  # Valid self-closing HTML 5 elements.
  void: 'area base br col command embed hr img input keygen link meta param
 source track wbr'

  obsolete: 'applet acronym bgsound dir frameset noframes isindex listing
 nextid noembed plaintext rb strike xmp big blink center font marquee multicol
 nobr spacer tt'

  obsolete_void: 'basefont frame'

# Create a unique list of element names merging the desired groups.
merge_elements = (args...) ->
  result = []
  for a in args
    for element in elements[a].split ' '
      result.push element unless result.indexOf(element) > -1
  result

# Public/customizable list of possible elements.
# For each name in this list that is also present in the input template code,
# a function with the same name will be added to the compiled template.
coffeemugg.tags = merge_elements 'regular', 'obsolete', 'void', 'obsolete_void'

# Public/customizable list of elements that should be rendered self-closed.
coffeemugg.self_closing = merge_elements 'void', 'obsolete_void'

# A unique token that represents a newline.
NEWLINE = new Object()

# The rendering context and renderer.
# Call CMContext.extend() to extend with more helper functions.
exports.CMContext = class CMContext
  # options:
  #   format:     Format with newlines and tabs (default off)
  #   autoescape: Autoescape all strings (default off)
  #   context:    Dynamically extend the CMContext instance
  constructor: (options) ->
    @buffer = "" # collect output
    @format = options?.format || off
    @newline = ''
    @indent = ''
    @autoescape = options?.autoescape || off
    this.extend(options.context) if options?.context?

  # procedurally add methods for each tag
  for tag in coffeemugg.tags.concat(coffeemugg.self_closing)
    do (tag) =>
      this::[tag] = ->
        this.render_tag(tag, arguments)

  esc: (txt) ->
    if @autoescape then @h(txt) else txt

  h: (txt) ->
    String(txt).replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')

  doctype: (type = 'default') ->
    @text @indent + coffeemugg.doctypes[type]

  text: (txt) ->
    @buffer += txt
    @newline = '\n'
    null

  tag: (name, args...) ->
    @render_tag(name, args)

  comment: (cmt) ->
    @text "#{@newline}#{@indent}<!--#{cmt}-->"
    NEWLINE

  ie: (condition, contents) ->
    @text "#{@newline}#{@indent}<!--[if #{condition}]>"
    @render_contents(contents)
    @text "<![endif]-->"
    NEWLINE

  coffeescript: (param) ->
    switch typeof param
      # `coffeescript -> alert 'hi'` becomes:
      # `<script>;(function () {return alert('hi');})();</script>`
      when 'function'
        @script "#{coffeescript_helpers}(#{param}).call(this);"
      # `coffeescript "alert 'hi'"` becomes:
      # `<script type="text/coffeescript">alert 'hi'</script>`
      when 'string'
        @script type: 'text/coffeescript', -> param
      # `coffeescript src: 'script.coffee'` becomes:
      # `<script type="text/coffeescript" src="script.coffee"></script>`
      when 'object'
        param.type = 'text/coffeescript'
        @script param

  render_tag: (name, args) ->
    # get idclass, attrs, contents
    for a in args
      switch typeof a
        when 'function'
          contents = a.bind(this)
        when 'object'
          attrs = a
        when 'number', 'boolean'
          contents = a
        when 'string'
          if args.length is 1
            contents = a
          else
            if a is args[0]
              idclass = a
            else
              contents = a
    @text "#{@newline}#{@indent}<#{name}"
    @render_idclass(idclass) if idclass
    @render_attrs(attrs) if attrs
    if name in coffeemugg.self_closing
      @text ' />'
    else
      @text '>'
      @render_contents(contents)
      @text "</#{name}>"
    NEWLINE

  render_idclass: (str) ->
    classes = []
    str = String(str).replace /"/, "&quot;"
    for i in str.split '.'
      if i[0] is '#'
        id = i[1..]
      else
        classes.push i unless i is ''
    @text " id=\"#{id}\"" if id
    @text " class=\"#{classes.join ' '}\"" if classes.length > 0

  render_attrs: (obj) ->
    for k, v of obj
      # true is rendered as `selected="selected"`.
      if typeof v is 'boolean' and v
        v = k
      # undefined, false and null result in the attribute not being rendered.
      if v
        # strings, numbers, objects, arrays and functions are rendered "as is".
        @text " #{k}=\"#{String(v).replace(/"/,"&quot;")}\""

  render: (contents, args...) ->
    if typeof contents is 'string' and coffee?
      eval "contents = function () {#{coffee.compile contents, bare: yes}}"
    @newline = ''
    if typeof contents is 'function'
      contents.call(this, args...)
    this

  render_contents: (contents, args...) ->
    if typeof contents is 'function'
      @indent += '  ' if @format
      contents = contents.call(this, args...)
      @indent = @indent[2..] if @format
      if contents is NEWLINE
        @text "#{@newline}#{@indent}"
    switch typeof contents
      when 'string', 'number', 'boolean'
        @text @esc(contents)
    null

  toString: ->
    @buffer

  # Extend the CMContext class
  # options:
  #   warn: if false, will not warn upon trampling existing keys (default true)
  @extend: (object, options) =>
    warn = options?.warn ? true
    class _ExtendedContext extends this
    for key, value of object
      if warn and this::[key]?
        logger.warn "@extend: Key `#{key}` already exists for this context."
      _ExtendedContext::[key] = value
    return _ExtendedContext

  # Extend this instance, dynamically
  # options:
  #   warn: if false, will not warn upon trampling existing keys (default true)
  extend: (object, options) ->
    warn = options?.warn ? true
    for key, value of object
      if warn and this[key]?
        logger.warn "extend: Key `#{key}` already exists for this context. (dynamic)"
      this[key] = value
    this

# convenience, render template to string
# options:
#   format:     Format with newlines and tabs (default off)
#   autoescape: Whether to autoescape all strings (default off)
#   context:    Dynamically extend the CMContext instance
coffeemugg.render = (template, options, args...) ->
  context = new CMContext(options)
  return context.render(template, args...).toString()
