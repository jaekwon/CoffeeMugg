CoffeeMugg
==========

 * Based on CoffeeKup.
 * Instead of local tag functions, most things are bound to `this`.
 * Subroutines (helper view functions) become possible!

    coffeemugg.render ->
      @div ->
        @p "I am a paragraph"
