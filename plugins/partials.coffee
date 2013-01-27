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

# This function returns the "plugin installer"
module.exports = (_require, dir, tag='partial') ->

  # This is the "plugin installer"
  ->

    # This is the "@partial" tag, or whatever you named it.
    @[tag] = (partialName, args...) ->

      hotswap(_require, "#{dir}/#{partialName}").partial.apply(@, args)

      null
