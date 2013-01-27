coffeemugg = require './lib/coffeemugg'
log = console.log
try
  coffeekup = require 'coffeecup'
catch e
  log "coffeecup not installed"
try
  jade = require 'jade'
catch e
  log "jade not installed"
try
  ejs = require 'ejs'
catch e
  log "ejs not installed"
try
  eco = require 'eco'
catch e
  log "eco not installed"
try
  haml = require 'haml'
catch e
  log "haml not installed"

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

coffeekup_template = ->
  doctype 5
  html lang: 'en', ->
    head ->
      meta charset: 'utf-8'
      title @title
      style '''
        body {font-family: "sans-serif"}
        section, header {display: block}
      '''
    body ->
      section ->
        header ->
          h1 @title
        if @inspired
          p 'Create a witty example'
        else
          p 'Go meta'
        ul ->
          for user in @users
            li user.name
            li -> a href: "mailto:#{user.email}", -> user.email

coffeekup_string_template = """
  doctype 5
  html lang: 'en', ->
    head ->
      meta charset: 'utf-8'
      title @title
      style '''
        body {font-family: "sans-serif"}
        section, header {display: block}
      '''
    body ->
      section ->
        header ->
          h1 @title
        if @inspired
          p 'Create a witty example'
        else
          p 'Go meta'
        ul ->
          for user in @users
            li user.name
            li -> a href: "mailto:\#{user.email}", -> user.email
"""

coffeekup_compiled_template = coffeekup.compile coffeekup_template if coffeekup

jade_template = '''
  !!! 5
  html(lang="en")
    head
      meta(charset="utf-8")
      title= title
      style
        | body {font-family: "sans-serif"}
        | section, header {display: block}
    body
      section
        header
          h1= title
        - if (inspired)
          p Create a witty example
        - else
          p Go meta
        ul
          - each user in users
            li= user.name
            li
              a(href="mailto:"+user.email)= user.email
'''

jade_compiled_template = jade.compile jade_template if jade

ejs_template = '''
  <!DOCTYPE html>
  <html lang="en">
    <head>
      <meta charset="utf-8">
      <title><%= title %></title>
      <style>
        body {font-family: "sans-serif"}
        section, header {display: block}
      </style>
    </head>
    <body>
      <section>
        <header>
          <h1><%= title %></h1>
        </header>
        <% if (inspired) { %>
          <p>Create a witty example</p>
        <% } else { %>
          <p>Go meta</p>
        <% } %>
        <ul>
          <% for (user in users) { %>
            <li><%= user.name %></li>
            <li><a href="mailto:<%= user.email %>"><%= user.email %></a></li>
          <% } %>
        </ul>
      </section>
    </body>
  </html>
'''

eco_template = '''
  <!DOCTYPE html>
  <html lang="en">
    <head>
      <meta charset="utf-8">
      <title><%= @title %></title>
      <style>
        body {font-family: "sans-serif"}
        section, header {display: block}
      </style>
    </head>
    <body>
      <section>
        <header>
          <h1><%= @title %></h1>
        </header>
        <% if @inspired: %>
          <p>Create a witty example</p>
        <% else: %>
          <p>Go meta</p>
        <% end %>
        <ul>
          <% for user in @users: %>
            <li><%= user.name %></li>
            <li><a href="mailto:<%= user.email %>"><%= user.email %></a></li>
          <% end %>
        </ul>
      </section>
    </body>
  </html>
'''

haml_template = '''
  !!! 5
  %html{lang: "en"}
    %head
      %meta{charset: "utf-8"}
      %title= title
      :css
        body {font-family: "sans-serif"}
        section, header {display: block}
    %body
      %section
        %header
          %h1= title
        :if inspired
          %p Create a witty example
        :if !inspired
          %p Go meta
        %ul
          :each user in users
            %li= user.name
            %li
              %a{href: "mailto:#{user.email}"}= user.email
'''

haml_template_compiled = haml(haml_template) if haml

benchmark = (title, code) ->
  start = new Date
  for i in [1..15000]
    code()
  log "#{title}: #{new Date - start} ms"

@run = ->
  benchmark 'CoffeeMugg (none)', -> coffeemugg.render coffeemugg_template
  benchmark 'CoffeeMugg (args)', -> coffeemugg.render coffeemugg_template_args, null, data
  benchmark 'CoffeeMugg (format) (none)', -> coffeemugg.render coffeemugg_template, format:on
  context = coffeemugg.CMContext()
  benchmark 'CoffeeMugg (reuse context)', ->
    context.reset().render coffeemugg_template

  console.log '\n'

  if coffeekup
    benchmark 'CoffeeKup (precompiled)', -> coffeekup_compiled_template data
  if jade
    benchmark 'Jade (precompiled)', -> jade_compiled_template data
  if haml
    benchmark 'haml-js (precompiled)', -> haml_template_compiled data
  if eco
    benchmark 'Eco', -> eco.render eco_template, data

  console.log '\n'

  if coffeekup
    benchmark 'CoffeeKup (function, cache on)', -> coffeekup.render coffeekup_template, data, cache: on
    benchmark 'CoffeeKup (string, cache on)', -> coffeekup.render coffeekup_string_template, data, cache: on
  ### broken
  if jade
    benchmark 'Jade (cache on)', -> jade.render jade_template, locals: data, cache: on, filename: 'test'
  ###
  if ejs
    benchmark 'ejs (cache on)', -> ejs.render ejs_template, locals: data, cache: on, filename: 'test'

  console.log '\n'

  ### broken
  if jade
    benchmark 'Jade (cache off)', -> jade.render jade_template, locals: data
  ###
  if haml
    benchmark 'haml-js', -> haml.render haml_template, locals: data
  if ejs
    benchmark 'ejs (cache off)', -> ejs.render ejs_template, locals: data
