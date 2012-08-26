delay = (t,f) -> setTimeout f, t

write = (data) ->
  log = document.getElementById "log"
  li = document.createElement "li"
  li.innerHTML = data
  log.appendChild li

ws = new WebSocket "ws://localhost:4567/ws/awesome"
ws.onmessage = (e) ->
  write e.data
  delay 2000, -> ws.send "Loop"

ws.onopen = -> ws.send "Ping!"

es = new EventSource "http://localhost:4567/ws/eurucamp"
es.onmessage = (e) -> write e.data