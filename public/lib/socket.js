// Generated by CoffeeScript 1.3.3
(function() {
  var delay, es, write, ws;

  delay = function(t, f) {
    return setTimeout(f, t);
  };

  write = function(data) {
    var li, log;
    log = document.getElementById("log");
    li = document.createElement("li");
    li.innerHTML = data;
    return log.appendChild(li);
  };

  ws = new WebSocket("ws://localhost:4567/ws/awesome");

  ws.onmessage = function(e) {
    write(e.data);
    return delay(2000, function() {
      return ws.send("Loop");
    });
  };

  ws.onopen = function() {
    return ws.send("Ping!");
  };

  es = new EventSource("http://localhost:4567/ws/eurucamp");

  es.onmessage = function(e) {
    return write(e.data);
  };

}).call(this);
