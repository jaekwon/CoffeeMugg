CoffeeMugg
==========

CoffeeMugg is a templating engine for [node.js](http://nodejs.org) and browsers that lets you to write your HTML templates in 100% pure [CoffeeScript](http://coffeescript.org).

CoffeeMugg is a branch of [CoffeeKup](https://github.com/mauricemach/coffeekup). The main difference is that instead of local tag functions, tag functions are bound to `this`.

## Why CoffeeMugg?

 * No magic compilation step: the template code runs as you would expect.
 * Local variables obey original Javascript/Coffeescript rules.
 * If you want to create a template dynamically using function closures, you can!
 * This makes it easier to create libraries of view-helper routines, in the manner of RoR ActionView.

## Sample

Basic example:
```coffeescript
cm = require 'coffeemugg'

cm.render ->
  @div ->
    @p "I am a paragraph"
    @raw "<p> This is unescaped, raw HTML </p>"
    @text "<< This will be escaped ! >>"
```

## Custom TAG functions (subroutines)

You can add custom @TAG functions to CoffeeMugg with 'plugins'.

```coffeescript
# Install custom tags! In this case, just the tag '@showFruits'
cm.install_plugin ->

  # The tag 'showFruits' will become available everywhere.
  # It is a regular function, so it can take arguments too, like 'fruits'
  @showFruits = (fruits) ->
    @ul ->
      for fruit in fruits
        @li fruit

# Here is the main template function.
# Notice that the main template function can also take javascript arguments.
template = (fruits) ->
  @div ->
    # Pass in 'fruits' to our custom '@showFruits' tag
    @showFruits fruits

# Options to CoffeeMugg
#   autoescape: The "text" values are automatically HTML escaped.
#               You can still use the '@raw' tag for unescaped text.
#               Default: yes
#   format:     The output HTML will be formatted all pretty.
#               Default: yes
options = {
  autoescape: yes
  format:     yes
}
fruits  = ['Apple', 'Banana', 'Raisin', 'Rice Crispies', 'Mickey Mouse']
cm.render template, options, fruits
```

## Sample plugins

Sample plugins are in the 'plugins' directory. The best way to use them is to copy them
into your project (which manages your dependencies), and install them via 'install_plugin':
``` coffeescript
cm = require 'coffeemugg'
# Use the 'marked' markdown language.
# Your project needs to have 'marked' as a dependency.
# Note, './plugins' is a folder in _your_ project.
cm.install_plugin require('./plugins/marked')
# Use the 'partials' system for templating ease.
# Note, './templates' is a folder in your project.
cm.install_plugin require('./plugins/partials')(require, './templates')

template = ->
  @p ->
    @marked "This is using __markdown__"
    @partial '_mypartial', 'myarg'
```

## Installation

    npm install coffeemugg
    
## Cli

Create static html files in CoffeeMugg syntax. It's adapted from coffeecup.
```
coffeemugg -h

Usage:
  coffeemugg [options] path/to/template.coffee

  -w, --watch        watch templates for changes, and recompile
  -o, --output       set the directory for compiled html
  -p, --print        print the compiled html to stdout, don't write file
  -f, --format       apply line breaks and indentation to html output
  -v, --version      display coffeemugg version
  -h, --help         display this help message
```

## More

Please take a look at the excellent [CoffeeScript](http://coffeescript.org) documentation for more information.

## Special thanks

  - [Jeremy Ashkenas](https://github.com/jashkenas), for the amazing CoffeeScript language.
  - [Maurice Machado](https://github.com/mauricemach), for CoffeeKup. Hope you're OK with this.
  - [W. Mertens](https://github.com/wmertens), for the latest contributions.
