app = require 'berliner'

app.public = __dirname + '/public'
app.views  = __dirname + '/views'
app.session_secret = 'abc123'

repeat = (t,f) -> setInterval f, t
app.helpers
  inc_counter: ->
    @session.counter ||= 0
    @session.counter += 1
  
  site_name: ->
    'Awesome.net'

app.before (next) ->
  @puts @request.method + ' ' + @request.url
  next()

app.get '/', ->
  @cookie message: {value: 'Sinatra; it’s a framework', path: '/hello'}
  @title = 'Almost Sinatra'
  @haml 'index'

app.get 'hello', ->
  @ejs 'hello', locals: 
    name: @params.name
    message: @cookies.message

app.get '/counter', ->
  @inc_counter()
  @render @session.counter

app.context '/auth', (auth) ->
  auth.before (next) ->
    if @request.headers.authorization
      next()
    else
      @status 401
      @render 'Authorization required'
  
  auth.get '/', ->
    'Secret stuff'
  
  auth.delete 'info', ->
    @status 418
    'I am a teapot'

app.get '/words/:category/:id.:format', ->
  JSON.stringify @params

app.get '/download/*.*', ->
  @params.splat.join ', '

app.put '/download/*.*', (path, ext) ->
  [path, ext].join ' // '

app.post '/', ->
  @status 201
  @headers 'Content-Type': 'application/json'
  JSON.stringify @params

app.get '/legacy', ->
  @redirect '/hello'

app.options '/', ->
  @headers 'Access-Control-Allow-Methods': 'GET, PUT, DELETE'
  @render ''

app.get '/file', ->
  @headers 'Content-Type': 'text/html'
  @response.write(fs.readFileSync(__dirname + '/sse-node.html'))
  @response.end()

app.eventsource '/stream', ->
  interval = Math.round((Number) @params.interval)
  buffsize = Math.round((Number) @params.buffsize)
  resolution = Math.round((Number) @params.resolution)
  repeat interval, => 
    points = []
    for p in [0..buffsize]
      points.push [
        Math.round(Math.random() * resolution)
        Math.round(Math.random() * resolution)
        Math.round(Math.random() * resolution)       
        Math.round(Math.random())
      ]
    @socket.send JSON.stringify(points)

app.template 'hello.ejs', """
Hello <%= name %>, welcome to <%= site_name() %>! Cookie: “<%= message %>”
"""

app.run process.env.PORT || 5000