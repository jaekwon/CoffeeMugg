###

A CoffeeMugg plugin for partials

Options:
  _require: pass in a require.
  dir: The base directory.
  tag: The name to give this tag, default '@partial'

Usage:

  -- ./helloworld.coffee --

  cm = require 'coffeemugg'
  cm.install_plugin require('plugins/partials')(require, './templates')
  
  template = ->
    @html ->
      @body ->
        @partial '_mypartial', arg1, arg2
  
  cm.render template

  -- ./templates/_mypartial.coffee --

  @partial = (arg1, arg2) ->
    @p "#{arg1} #{arg2}"

###


{hotswap} = require 'cardamom'

module.exports = (_require, dir, tag='partial') -> ->

  @[tag] = partialTag = (partialName, args...) ->

    hotswap(_require, "#{dir}/#{partialName}").partial.apply(@, args)
