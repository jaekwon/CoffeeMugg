CoffeeMugg
==========

 * Based on [CoffeeKup](https://github.com/mauricemach/coffeekup).
 * Instead of local tag functions, tag functions are bound to `this`.
 * Efficient view helper libraries are possible. CoffeeKup does not
   support subroutines unless all subroutines are first serialized to code
   and re-evaluated. This is a natural limitation of javascript when
   using CoffeeKup-style local tag functions.

sample:

    coffeemugg.render ->
      @div ->
        @p "I am a paragraph"

sample with coroutines:

    # Create a new class with all the subroutines
    MyContext = CMContext.extend({
      myroutine: ->
        @p 'blah blah'
    })
    
    # Create a rendering instance
    context = new MyContext()
    context.render_contents ->
      @div ->
        @myroutine()

Special thanks
==============

  - [Jeremy Ashkenas](https://github.com/jashkenas), for the amazing CoffeeScript language.
  - [Maurice Machado](https://github.com/mauricemach), for CoffeeKup.
