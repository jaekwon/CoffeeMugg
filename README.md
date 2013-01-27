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

You can add custom @TAG functions to coffeemugg with 'plugins'.

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

options = {autoescape:yes}
fruits  = ['Apple', 'Banana', 'Raisin', 'Rice Crispies', 'Mickey Mouse']
cm.render template, options, fruits
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
