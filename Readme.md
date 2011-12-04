CoffeeMugg
==========

 * Based on CoffeeKup.
 * Instead of local tag functions, most things are bound to `this`.
 * Subroutines (helper view functions) become possible.

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
