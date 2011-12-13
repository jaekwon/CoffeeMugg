(function() {
  var CMContext, NEWLINE, coffeemugg, elements, logger, merge_elements;
  var __slice = Array.prototype.slice, __hasProp = Object.prototype.hasOwnProperty, __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (__hasProp.call(this, i) && this[i] === item) return i; } return -1; }, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  if (typeof window !== "undefined" && window !== null) {
    coffeemugg = window.CoffeeMug = {};
    logger = {
      debug: function(msg) {
        return console.log("debug: " + msg);
      },
      info: function(msg) {
        return console.log("info: " + msg);
      },
      warn: function(msg) {
        return console.log("warn: " + msg);
      },
      error: function(msg) {
        return console.log("error: " + msg);
      }
    };
  } else {
    coffeemugg = exports;
    logger = require('nogg').logger('coffeemugg');
  }

  coffeemugg.version = '0.0.2';

  coffeemugg.doctypes = {
    'default': '<!DOCTYPE html>',
    '5': '<!DOCTYPE html>',
    'xml': '<?xml version="1.0" encoding="utf-8" ?>',
    'transitional': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
    'strict': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
    'frameset': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">',
    '1.1': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">',
    'basic': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">',
    'mobile': '<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">',
    'ce': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "ce-html-1.0-transitional.dtd">'
  };

  elements = {
    regular: 'a abbr address article aside audio b bdi bdo blockquote body button\
 canvas caption cite code colgroup datalist dd del details dfn div dl dt em\
 fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hgroup\
 html i iframe ins kbd label legend li map mark menu meter nav noscript object\
 ol optgroup option output p pre progress q rp rt ruby s samp script section\
 select small span strong style sub summary sup table tbody td textarea tfoot\
 th thead time title tr u ul video',
    "void": 'area base br col command embed hr img input keygen link meta param\
 source track wbr',
    obsolete: 'applet acronym bgsound dir frameset noframes isindex listing\
 nextid noembed plaintext rb strike xmp big blink center font marquee multicol\
 nobr spacer tt',
    obsolete_void: 'basefont frame'
  };

  merge_elements = function() {
    var a, args, element, result, _i, _j, _len, _len2, _ref;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    result = [];
    for (_i = 0, _len = args.length; _i < _len; _i++) {
      a = args[_i];
      _ref = elements[a].split(' ');
      for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
        element = _ref[_j];
        if (!(result.indexOf(element) > -1)) result.push(element);
      }
    }
    return result;
  };

  coffeemugg.tags = merge_elements('regular', 'obsolete', 'void', 'obsolete_void');

  coffeemugg.self_closing = merge_elements('void', 'obsolete_void');

  NEWLINE = new Object();

  exports.CMContext = CMContext = (function() {
    var tag, _fn, _i, _len, _ref;
    var _this = this;

    function CMContext(options) {
      this.buffer = [];
      this.format = (options != null ? options.format : void 0) || false;
      this.autoescape = (options != null ? options.autoescape : void 0) || false;
      if ((options != null ? options.context : void 0) != null) {
        this.extend(options.context);
      }
    }

    _ref = coffeemugg.tags.concat(coffeemugg.self_closing);
    _fn = function(tag) {
      return CMContext.prototype[tag] = function() {
        return this.render_tag(tag, arguments);
      };
    };
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      tag = _ref[_i];
      _fn(tag);
    }

    CMContext.prototype.esc = function(txt) {
      if (this.autoescape) {
        return this.h(txt);
      } else {
        return String(txt);
      }
    };

    CMContext.prototype.h = function(txt) {
      return String(txt).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    };

    CMContext.prototype.doctype = function(type) {
      if (type == null) type = 'default';
      this.text(coffeemugg.doctypes[type]);
      return this.newline();
    };

    CMContext.prototype.text = function(txt) {
      this.buffer.push(String(txt));
      return null;
    };

    CMContext.prototype.newline = function() {
      this.buffer.push(NEWLINE);
      return null;
    };

    CMContext.prototype.indent = function(fn) {
      var newbuffer, oldbuffer;
      oldbuffer = this.buffer;
      this.buffer = newbuffer = [];
      fn.call(this);
      if (newbuffer.length > 0) oldbuffer.push(newbuffer);
      this.buffer = oldbuffer;
      return null;
    };

    CMContext.prototype.tag = function() {
      var args, name;
      name = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return this.render_tag(name, args);
    };

    CMContext.prototype.comment = function(cmt) {
      this.text("<!--" + cmt + "-->");
      return this.newline();
    };

    CMContext.prototype.ie = function(condition, contents) {
      this.text("<!--[if " + condition + "]>");
      this.render_contents(contents);
      this.text("<![endif]-->");
      return this.newline();
    };

    CMContext.prototype.repeat = function(string, count) {
      return Array(count + 1).join(string);
    };

    CMContext.prototype.render_tag = function(name, args) {
      var a, attrs, contents, idclass, _j, _len2;
      for (_j = 0, _len2 = args.length; _j < _len2; _j++) {
        a = args[_j];
        switch (typeof a) {
          case 'function':
            contents = a.bind(this);
            break;
          case 'object':
            attrs = a;
            break;
          case 'number':
          case 'boolean':
            contents = a;
            break;
          case 'string':
            if (args.length === 1) {
              contents = a;
            } else {
              if (a === args[0]) {
                idclass = a;
              } else {
                contents = a;
              }
            }
        }
      }
      this.text("<" + name);
      if (idclass) this.render_idclass(idclass);
      if (attrs) this.render_attrs(attrs);
      if (__indexOf.call(coffeemugg.self_closing, name) >= 0) {
        this.text(' />');
        this.newline();
      } else {
        this.text('>');
        this.render_contents(contents);
        this.text("</" + name + ">");
        this.newline();
      }
      return null;
    };

    CMContext.prototype.render_idclass = function(str) {
      var c, classes, i, id, _j, _k, _len2, _len3, _ref2;
      classes = [];
      _ref2 = str.split('.');
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        i = _ref2[_j];
        if (i.indexOf('#') === 0) {
          id = i.replace('#', '');
        } else {
          if (i !== '') classes.push(i);
        }
      }
      if (id) this.text(" id=\"" + id + "\"");
      if (classes.length > 0) {
        this.text(" class=\"");
        for (_k = 0, _len3 = classes.length; _k < _len3; _k++) {
          c = classes[_k];
          if (c !== classes[0]) this.text(' ');
          this.text(c);
        }
        return this.text('"');
      }
    };

    CMContext.prototype.render_attrs = function(obj) {
      var k, v, _results;
      _results = [];
      for (k in obj) {
        v = obj[k];
        if (typeof v === 'boolean' && v) v = k;
        if (v) {
          _results.push(this.text(" " + k + "=\"" + (this.esc(v)) + "\""));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    CMContext.prototype.render_contents = function() {
      var args, contents, result;
      contents = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      switch (typeof contents) {
        case 'string':
        case 'number':
        case 'boolean':
          this.text(this.esc(contents));
          break;
        case 'function':
          if (this.format) {
            this.indent(function() {
              var result;
              return result = contents.call.apply(contents, [this].concat(__slice.call(args)));
            });
          } else {
            result = contents.call.apply(contents, [this].concat(__slice.call(args)));
          }
          if (typeof result === 'string') this.text(this.esc(result));
      }
      return this;
    };

    CMContext.prototype.toString = function() {
      var _2str;
      var _this = this;
      _2str = function(buffer, indent) {
        var content, indents, prefix, suffix, tab;
        tab = '  ';
        indents = _this.format ? _this.repeat(tab, indent) : '';
        prefix = _this.format && indent > 0 ? '\n' + _this.repeat(tab, indent) : '';
        suffix = _this.format && indent > 0 ? '\n' + _this.repeat(tab, indent - 1) : '';
        content = buffer.map(function(value, i) {
          if (typeof value === 'string') {
            return value;
          } else if (value === NEWLINE) {
            if (i < buffer.length - 1) return '\n' + indents;
          } else if (value instanceof Array) {
            return _2str(value, indent + 1);
          } else {
            throw new Error("Unknown type in buffer " + (typeof value));
          }
        }).join('');
        return prefix + content + suffix;
      };
      if (this.buffer[0] instanceof Array) {
        return _2str(this.buffer[0], 0);
      } else {
        return _2str(this.buffer, 0);
      }
    };

    CMContext.prototype.debugString = function() {
      var _2str;
      var _this = this;
      _2str = function(buffer, indent) {
        var content, indents, indents_1, value;
        indents = (_this.format ? _this.repeat('  ', indent) : '');
        indents_1 = (_this.format ? _this.repeat('  ', indent + 1) : '');
        content = ((function() {
          var _j, _len2, _results;
          _results = [];
          for (_j = 0, _len2 = buffer.length; _j < _len2; _j++) {
            value = buffer[_j];
            if (typeof value === 'string') {
              _results.push(indents_1 + value);
            } else if (value === NEWLINE) {
              _results.push(indents_1 + 'NEWLINE');
            } else if (value instanceof Array) {
              _results.push(_2str(value, indent + 1));
            } else {
              throw new Error("Unknown type in buffer " + (typeof value));
            }
          }
          return _results;
        })()).join("\n");
        return "" + indents + "[\n" + content + "\n" + indents + "]";
      };
      return _2str(this.buffer, 0);
    };

    CMContext.extend = function(object, options) {
      var key, value, warn, _ExtendedContext, _ref2;
      warn = (_ref2 = options != null ? options.warn : void 0) != null ? _ref2 : true;
      _ExtendedContext = (function() {

        __extends(_ExtendedContext, this);

        function _ExtendedContext() {
          _ExtendedContext.__super__.constructor.apply(this, arguments);
        }

        return _ExtendedContext;

      }).call(CMContext);
      for (key in object) {
        value = object[key];
        if (warn && (CMContext.prototype[key] != null)) {
          logger.warn("@extend: Key `" + key + "` already exists for this context.");
        }
        _ExtendedContext.prototype[key] = value;
      }
      return _ExtendedContext;
    };

    CMContext.prototype.extend = function(object, options) {
      var key, value, warn, _ref2;
      warn = (_ref2 = options != null ? options.warn : void 0) != null ? _ref2 : true;
      for (key in object) {
        value = object[key];
        if (warn && (this[key] != null)) {
          logger.warn("extend: Key `" + key + "` already exists for this context. (dynamic)");
        }
        this[key] = value;
      }
      return this;
    };

    return CMContext;

  }).call(this);

  coffeemugg.render = function() {
    var args, context, options, template;
    template = arguments[0], options = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
    context = new CMContext(options);
    return context.render_contents.apply(context, [template].concat(__slice.call(args))).toString();
  };

  coffeemugg.debug = function() {
    var args, context, options, template, _ref;
    template = arguments[0], options = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
    if (options) if ((_ref = options.format) == null) options.format = true;
    context = new CMContext(options);
    return console.log(context.render_contents.apply(context, [template].concat(__slice.call(args))).debugString());
  };

}).call(this);
