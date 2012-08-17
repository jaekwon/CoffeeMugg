coffeemugg = require './src/coffeemugg'
profiler = require 'profiler'

log = console.log

data =
  title: 'test'
  inspired: no
  users: [
    {email: 'house@gmail.com', name: 'house'}
    {email: 'cuddy@gmail.com', name: 'cuddy'}
    {email: 'wilson@gmail.com', name: 'wilson'}
  ]

coffeemugg_template = ->
  @doctype 5
  @html lang: 'en', ->
    @head ->
      @meta charset: 'utf-8'
      @title data.title
      @style '''
        body {font-family: "sans-serif"}
        section, header {display: block}
      '''
    @body ->
      @section ->
        @header ->
          @h1 data.title
        if data.inspired
          @p 'Create a witty example'
        else
          @p 'Go meta'
        @ul ->
          for user in data.users
            @li user.name
            @li -> @a href: "mailto:#{user.email}", -> user.email

coffeemugg_template_args = (data) ->
  @doctype 5
  @html lang: 'en', ->
    @head ->
      @meta charset: 'utf-8'
      @title data.title
      @style '''
        body {font-family: "sans-serif"}
        section, header {display: block}
      '''
    @body ->
      @section ->
        @header ->
          @h1 data.title
        if data.inspired
          @p 'Create a witty example'
        else
          @p 'Go meta'
        @ul ->
          for user in data.users
            @li user.name
            @li -> @a href: "mailto:#{user.email}", -> user.email

coffeemugg_template_context = ->
  @doctype 5
  @html lang: 'en', ->
    @head ->
      @meta charset: 'utf-8'
      @title @data.title
      @style '''
        body {font-family: "sans-serif"}
        section, header {display: block}
      '''
    @body ->
      @section ->
        @header ->
          @h1 @data.title
        if @data.inspired
          @p 'Create a witty example'
        else
          @p 'Go meta'
        @ul ->
          for user in @data.users
            @li user.name
            @li -> @a href: "mailto:#{user.email}", -> user.email


benchmark = (title, code) ->
  start = new Date
  profiler.resume()
  for i in [1..15000]
    code()
  profiler.pause()
  log "#{title}: #{new Date - start} ms"

@run = ->
  benchmark 'CoffeeMugg (none)', -> coffeemugg.render coffeemugg_template
  #benchmark 'CoffeeMugg (args)', -> coffeemugg.render coffeemugg_template_args, null, data
  #benchmark 'CoffeeMugg (context)', -> coffeemugg.render coffeemugg_template_context, context: {data: data}
  #benchmark 'CoffeeMugg (format) (none)', -> coffeemugg.render coffeemugg_template, format: on

@run()
