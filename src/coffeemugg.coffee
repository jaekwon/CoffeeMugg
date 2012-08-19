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

# A unique object that represents a newline.
NEWLINE = {}

# The rendering context and renderer.
# 
# Usage:
# 
#   context = CMContext({
#     format:yes,
#     autoescape:yes,
#     plugins:['sample_plugin_module']
#   })
#   result = context.render(myTemplateFunction, args...)
# 
# options:
#   format:     Format with newlines and tabs (default off)
#   autoescape: Autoescape all strings (default off)
#   plugins:    Array of plugins, which are functions that take a context as argument.
# 
coffeemugg.CMContext = CMContext = (options={}) ->
  options.format      ||= on
  options.autoescape  ||= off

  context =
    options:   options
    _buffer:   ''
    _newline:  ''
    _indent:   ''

    # Main entry function for a context object
    render: (contents, args...) ->
      if typeof contents is 'string' and coffee?
        eval "contents = function () {#{coffee.compile contents, bare: yes}}"
      @reset()
      if typeof contents is 'function'
        contents.call(this, args...)
      this

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
      @text "#{@_newline}#{@_indent}<#{name}"
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

    render_contents: (contents, args...) ->
      if typeof contents is 'function'
        @_indent += '  ' if @options.format
        contents = contents.call(this, args...)
        @_indent = @_indent[2..] if @options.format
        if contents is NEWLINE
          @text "#{@_newline}#{@_indent}"
      switch typeof contents
        when 'string', 'number', 'boolean'
          @text @esc(contents)
      null

    esc: (txt) ->
      if @options.autoescape then @h(txt) else txt

    h: (txt) ->
      String(txt).replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')

    doctype: (type = 'default') ->
      @text @_indent + coffeemugg.doctypes[type]

    text: (txt) ->
      @_buffer += txt
      @_newline = '\n' if @options.format
      null

    tag: (name, args...) ->
      @render_tag(name, args)

    comment: (cmt) ->
      @text "#{@_newline}#{@_indent}<!--#{cmt}-->"
      NEWLINE

    toString: ->
      @_buffer

    reset: ->
      @_buffer  = ''
      @_newline = ''
      @_indent  = ''
      return @

  # Install plugins
  plugins = options.plugins ? []
  plugins.unshift HTMLPlugin
  for plugin in plugins
    plugin = require(plugin) if typeof plugin is 'string'
    plugin(context)
  
  return context

# This is what a plugin looks like.
# HTMLPlugin is installed by default.
HTMLPlugin = (context) ->

  # Tag functions
  for tag in coffeemugg.tags.concat(coffeemugg.self_closing) then do (tag) =>
    context[tag] = ->
      @render_tag(tag, arguments)

  # Special functions
  context.ie = (condition, contents) ->
    @text "#{@_newline}#{@_indent}<!--[if #{condition}]>"
    @render_contents(contents)
    @text "<![endif]-->"
    NEWLINE

  # CoffeeScript-generated JavaScript may contain anyone of these; but when we
  # take a function to string form to manipulate it, and then recreate it through
  # the `Function()` constructor, it loses access to its parent scope and
  # consequently to any helpers it might need. So we need to reintroduce these
  # inside any "rewritten" function.
  # From coffee-script/lib/coffee-script/nodes.js under UTILITIES
  coffeescript_helpers = """
    var __extends = function(child, parent) {
      for (var key in parent) {
        if (__hasProp.call(parent, key)) child[key] = parent[key];
      }
      function ctor() { this.constructor = child; }
      ctor.prototype = parent.prototype;
      child.prototype = new ctor();
      child.__super__ = parent.prototype;
      return child;
    },
    __bind = function(fn, me){
      return function(){ return fn.apply(me, arguments); };
    },
    __indexOf = [].indexOf || function(item) {
      for (var i = 0, l = this.length; i < l; i++) {
        if (i in this && this[i] === item) return i;
      }
      return -1;
    },
    __hasProp = {}.hasOwnProperty,
    __slice = [].slice;
  """.replace(/\ +/g, ' ').replace /\n/g, ''

  context.coffeescript = (param) ->
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

    css_props = '''
      align-content align-items align-self alignment-adjust alignment-baseline
      anchor-point animation animation-delay animation-direction animation-duration
      animation-iteration-count animation-name animation-play-state
      animation-timing-function appearance azimuth backface-visibility background
      background-attachment background-clip background-color background-image
      background-origin background-position background-repeat background-size
      baseline-shift binding bleed bookmark-label bookmark-level bookmark-state
      bookmark-target border border-bottom border-bottom-color
      border-bottom-left-radius border-bottom-right-radius border-bottom-style
      border-bottom-width border-collapse border-color border-image
      border-image-outset border-image-repeat border-image-slice
      border-image-source border-image-width border-left border-left-color
      border-left-style border-left-width border-radius border-right
      border-right-color border-right-style border-right-width border-spacing
      border-style border-top border-top-color border-top-left-radius
      border-top-right-radius border-top-style border-top-width border-width bottom
      box-decoration-break box-shadow box-sizing break-after break-before
      break-inside caption-side clear clip color color-profile column-count
      column-fill column-gap column-rule column-rule-color column-rule-style
      column-rule-width column-span column-width columns content counter-increment
      counter-reset crop cue cue-after cue-before cursor direction display
      dominant-baseline drop-initial-after-adjust drop-initial-after-align
      drop-initial-before-adjust drop-initial-before-align drop-initial-size
      drop-initial-value elevation empty-cells fit fit-position flex flex-basis
      flex-direction flex-flow flex-grow flex-shrink flex-wrap float float-offset
      font font-feature-settings font-family font-kerning font-language-override
      font-size font-size-adjust font-stretch font-style font-synthesis font-variant
      font-variant-alternates font-variant-caps font-variant-east-asian
      font-variant-ligatures font-variant-numeric font-variant-position font-weight
      hanging-punctuation height hyphens icon image-orientation image-rendering
      image-resolution inline-box-align justify-content left letter-spacing
      line-break line-height line-stacking line-stacking-ruby line-stacking-shift
      line-stacking-strategy list-style list-style-image list-style-position
      list-style-type margin margin-bottom margin-left margin-right margin-top
      marker-offset marks marquee-direction marquee-loop marquee-play-count
      marquee-speed marquee-style max-height max-width min-height min-width move-to
      nav-down nav-index nav-left nav-right nav-up opacity order orphans outline
      outline-color outline-offset outline-style outline-width overflow
      overflow-style overflow-wrap overflow-x overflow-y padding padding-bottom
      padding-left padding-right padding-top page page-break-after page-break-before
      page-break-inside page-policy pause pause-after pause-before perspective
      perspective-origin pitch pitch-range play-during position presentation-level
      punctuation-trim quotes rendering-intent resize rest rest-after rest-before
      richness right rotation rotation-point ruby-align ruby-overhang ruby-position
      ruby-span size speak speak-as speak-header speak-numeral speak-punctuation
      speech-rate stress string-set tab-size table-layout target target-name
      target-new target-position text-align text-align-last text-decoration
      text-decoration-color text-decoration-line text-decoration-skip
      text-decoration-style text-emphasis text-emphasis-color text-emphasis-position
      text-emphasis-style text-height text-indent text-justify text-outline
      text-shadow text-space-collapse text-transform text-underline-position
      text-wrap top transform transform-origin transform-style transition
      transition-delay transition-duration transition-property
      transition-timing-function unicode-bidi vertical-align visibility voice-balance
      voice-duration voice-family voice-pitch voice-range voice-rate voice-stress
      voice-volume volume white-space widows width word-break word-spacing word-wrap
      z-index 
    '''.split(/\s+/)
    valid_css_prop = {}
    for p in css_props
      valid_css_prop[p] = true
    
    # TODO: prefixing of e.g. border-radius
    parse_prop = (prop, val, parent) ->
      #  _ to -
      t = prop.replace /_/g, '-'
      prop = t if valid_css_prop[t]
      if typeof val is 'object'
        # subselector
        # Not great-looking CSS here
        @text "#{@_newline}#{@_indent}}"
        parse_selector.call @, prop, val, parent
        @text "#{@_newline}#{@_indent}#{parent} {"
      else if typeof val is 'number'
        @text "#{@_newline}#{@_indent}#{prop}: #{val}#{@unit};" 
      else
        @text "#{@_newline}#{@_indent}#{prop}: #{val};" 

    parse_selector = (selector, obj, parent) ->
      if parent
        # Rewrite our selector using the parent
        selectors = for p in parent.split /\s*,\s*/
          for s in selector.split /\s*,\s*/
            if s.indexOf('&') >= 0
              s.replace /&/g, p
            else
              "#{p} #{s}"
        selector = selectors.join ','

      @text "#{@_newline}#{@_indent}#{selector} {"
      @_indent += '  ' if @options.format
      if obj instanceof Array
        for o in obj then for prop, val of o
          parse_prop.call @, prop, val, selector
      else if typeof obj is 'object'
        for prop, val of obj
          parse_prop.call @, prop, val, selector
      else
        throw new Error "Don't know what to do with #{obj}"
      @_indent = @_indent[2..] if @options.format
      @text "#{@_newline}#{@_indent}}"

    context.unit = 'px'
    context.css = (args...) ->
      for arg in args
        if arg instanceof Array
          for obj in arg
            for k, v of obj
              parse_selector.call @, k, v
        else if typeof arg is 'object'
          for k, v of arg
            parse_selector.call @, k, v
        else
          throw new Error "@css takes objects or arrays of objects"

  return context

# Convenience, render template to string using the global renderer.
# options:
#   format:     Format with newlines and tabs (default off)
#   autoescape: Whether to autoescape all strings (default off)
g_context = undefined
coffeemugg.render = (template, options, args...) ->
  if options?.plugins?
    throw new Error "To install plugins to the global renderer, you must call coffeemugg.install_plugin."
  g_context ?= CMContext()
  g_context.options = options if options?
  return g_context.render(template, args...).toString()

# Conveience, add a plugin to the global renderer.
coffeemugg.install_plugin = (plugin) ->
  plugin = require(plugin) if typeof plugin is 'string'
  plugin(g_context)
