CoffeeMugg
==========

CoffeeMugg is a templating engine for [node.js](http://nodejs.org) and browsers that lets you to write your HTML templates in 100% pure [CoffeeScript](http://coffeescript.org).

CoffeeMugg is a branch of [CoffeeKup](https://github.com/mauricemach/coffeekup). The main difference is that instead of local tag functions, tag functions are bound to `this`.

Why CoffeeMugg?
===============

 * First, a disclaimer: I can't vouch for the usefulness of this branch just yet.
 * I believe this makes it easier to create libraries of view-helper routines, in the manner of RoR ActionView.
 * CoffeeMugg is easier to grok than CoffeeKup, since it's straight up Javascript/Coffeescript without an intermediate compilation step, and local variables obey original Javascript/Coffeescript rules. If you want to create a template dynamically using function closures, why go ahead.
 * There is no compilation step, so rendering on the client may be faster.

Sample
======

    coffeemugg.render ->
      @div ->
        @p "I am a paragraph"

with subroutines:

    # Create a new class with all the subroutines
    MyContext = CMContext.extend({
      myroutine: ->
        @p 'blah blah'
    })
    
    # Create a rendering instance
    context = new MyContext()
    context.render ->
      @div ->
        @myroutine()

with arguments:

    template = (div_id, contents) ->
      @div id: #div_id, ->
        for content in contents
          @div content

    coffeemugg.render template, <OPTIONS>, "FRUITS", ["Apple", "Banana", "Raisin"]

More
====

Please take a look at the excellent [CoffeeScript](http://coffeescript.org) documentation for more information.

Special thanks
==============

  - [Jeremy Ashkenas](https://github.com/jashkenas), for the amazing CoffeeScript language.
  - [Maurice Machado](https://github.com/mauricemach), for CoffeeKup. Hope you're OK with this.
