if window?
  coffeemugg = window.CoffeeMug = {}
else
  coffeemugg = exports

coffeemugg.version = '0.0.1alpha'

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

# The context under which rendering happens --
# 1. Output is aggregated here via this.buffer.push <string>
# 2. This provides all the tag functions like 'text', 'div', etc.
#FIRST -> the basic functions
#SECOND -> the extensions
#THIRD -> the context variables like buffer, tab, options.

class CMContext
  constructor: (options) ->
    @buffer = []                              # collect output
    @tabs = 0                                 # count indentation
    @format = options?.format || off
    @autoescape = options?.autoescape || off

  # procedurally add methods for each tag
  for tag in coffeemugg.tags.concat(coffeemugg.self_closing)
    do (tag) =>
      this::[tag] = (args...) ->
        this.render_tag(tag, args...)

  esc: (txt) ->
    if @autoescape then @h(txt) else String(txt)

  h: (txt) ->
    String(txt).replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')

  doctype: (type = 'default') ->
    @text coffeemugg.doctypes[type]
    @text '\n' if @format

  text: (txt) ->
    @buffer.push String(txt)
    null

  comment: (cmt) ->
    @text "<!--#{cmt}-->"
    @text '\n' if @format

  # Conditional IE comments.
  ie: (condition, contents) ->
    @indent()
    @text "<!--[if #{condition}]>"
    @render_contents(contents)
    @text "<![endif]-->"
    @text '\n' if @format

  repeat: (string, count) -> Array(count + 1).join string

  indent: -> @text @repeat('  ', @tabs) if @format

  render_tag: (name, args...) ->
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
    @indent()
    @text "<#{name}"
    @render_idclass(idclass) if idclass
    @render_attrs(attrs) if attrs
    if name in coffeemugg.self_closing
      @text ' />'
      @text '\n' if @format
    else
      @text '>'
      @render_contents(contents)
      @text "</#{name}>"
      @text '\n' if @format
    null

  render_idclass: (str) ->
    classes = []
    for i in str.split '.'
      if i.indexOf('#') is 0
        id = i.replace '#', ''
      else
        classes.push i unless i is ''
    @text " id=\"#{id}\"" if id
    if classes.length > 0
      @text " class=\""
      for c in classes
        @text ' ' unless c is classes[0]
        @text c
      @text '"'

  render_attrs: (obj) ->
    for k, v of obj
      # true is rendered as `selected="selected"`.
      if typeof v is 'boolean' and v
        v = k
      # undefined, false and null result in the attribute not being rendered.
      if v
        # strings, numbers, objects, arrays and functions are rendered "as is".
        @text " #{k}=\"#{@esc(v)}\""

  render_contents: (contents) ->
    switch typeof contents
      when 'string', 'number', 'boolean'
        @text @esc(contents)
      when 'function'
        @text '\n' if @format
        @tabs++
        result = contents.call this
        if typeof result is 'string'
          @indent()
          @text @esc(result)
          @text '\n' if @format
        @tabs--
        @indent()

  @extend: (object) =>
    class _ExtendedContext extends this
    for key, value of object
      _ExtendedContext.prototype[key] = value
    return _ExtendedContext

coffeemugg.render = (template) ->
  context = new CMContext()
  context.render_contents(template)
  console.log context.buffer.join('')

# Testing extensions
MyContext = CMContext.extend({
  test: ->
    @p "test was successful ?!"
})
context = new MyContext()
context.render_contents ->
  @div "hi", ->
    @test()
  @p "#id.class", ->
    @ul key: 'value', ->
      @li "blah"
      @li "blah"
console.log context.buffer.join('')
