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
coffeemugg.render ->
  @div ->
    @p "I am a paragraph"
```

With subroutines:
```coffeescript
subroutines = {
  myroutine: ->
    @p 'blah blah'
}

template = ->
  @div ->
    @myroutine()

coffeemugg.render template, {context: subroutines}
```

With arguments:
```coffeescript
template = (div_id, contents) ->
  @div id:div_id, ->
    for content in contents
      @div content

coffeemugg.render template, <OPTIONS>, "FRUITS", ["Apple", "Banana", "Raisin"]
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
