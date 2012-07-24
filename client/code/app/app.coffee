### QUICK CHAT DEMO ####

# Delete this file once you've seen how the demo works

# Listen out for newMessage events coming from the server
ss.event.on 'newMessage', (message) ->

  # Example of using the Hogan Template in client/templates/chat/message.jade to generate HTML for each message
  html = ss.tmpl['chat-message'].render
    message: message
    time: -> timestamp()

  # Append it to the #chatlog div and show effect
  $(html).hide().appendTo('#chatlog').slideDown()


# Show the chat form and bind to the submit action
$('#demo').on 'submit', ->

  # Grab the message from the text box
  text = $('#myMessage').val()

  # Call the 'send' funtion (below) to ensure it's valid before sending to the server
  exports.send text, (success) ->
    if success
      $('#myMessage').val('') # clear text box
    else
      alert('Oops! Unable to send message')


# Demonstrates sharing code between modules by exporting function
exports.send = (text, cb) ->
  if valid(text)
    ss.rpc('demo.sendMessage', text, cb)
  else
    cb(false)


# Private functions

timestamp = ->
  d = new Date()
  d.getHours() + ':' + pad2(d.getMinutes()) + ':' + pad2(d.getSeconds())

pad2 = (number) ->
  (if number < 10 then '0' else '') + number

valid = (text) ->
  text && text.length > 0



info = document.createElement("div")
info.id = "info"
info.innerHTML = "<a href=\"http://github.com/mrdoob/three.js\" target=\"_blank\">three.js</a> - kinect"
document.body.appendChild info
stats = new Stats()
stats.domElement.style.position = "absolute"
stats.domElement.style.top = "0px"
scene = new THREE.Scene()
center = new THREE.Vector3()
center.z = -1000
camera = new THREE.PerspectiveCamera(50, window.innerWidth / window.innerHeight, 1, 10000)
camera.position.set 0, 0, 500
scene.add camera


width = 2000
height = 2000
nearClipping = 850
farClipping = 4000
geometry = new THREE.Geometry()
i = 0
l = width * height

while i < l
  vertex = new THREE.Vector3()
  vertex.x = (i % width)
  vertex.y = Math.floor(i / width)
  geometry.vertices.push vertex
  i++
material = new THREE.ShaderMaterial
  uniforms:
    map:
      type: "t"
      value: 0
      texture: null

    width:
      type: "f"
      value: width

    height:
      type: "f"
      value: height

    nearClipping:
      type: "f"
      value: nearClipping

    farClipping:
      type: "f"
      value: farClipping

    pointSize:
      type: "f"
      value: 2

    zOffset:
      type: "f"
      value: 1000

  vertexShader: """
    uniform sampler2D map;

    uniform float width;
    uniform float height;
    uniform float nearClipping, farClipping;

    uniform float pointSize;
    uniform float zOffset;

    varying vec2 vUv;

    const float XtoZ = 1.11146; // tan( 1.0144686 / 2.0 ) * 2.0;
    const float YtoZ = 0.83359; // tan( 0.7898090 / 2.0 ) * 2.0;

    void main() {

      vUv = vec2( position.x / width, 1.0 - ( position.y / height ) );

      vec4 color = texture2D( map, vUv );
      float depth = ( color.r + color.g + color.b ) / 3.0;

      // Projection code by @kcmic

      float z = ( 1.0 - depth ) * (farClipping - nearClipping) + nearClipping;

      vec4 pos = vec4(
        ( position.x / width - 0.5 ) * z * XtoZ,
        ( position.y / height - 0.5 ) * z * YtoZ,
        - z + zOffset,
        1.0);

      gl_PointSize = pointSize;
      gl_Position = projectionMatrix * modelViewMatrix * pos;

    }
    """
  fragmentShader: """
    uniform sampler2D map;
    varying vec2 vUv;
    void main() {
      vec4 color = texture2D( map, vUv );
      gl_FragColor = vec4( color.r, color.g, color.b, smoothstep( 8000.0, -8000.0, gl_FragCoord.z / gl_FragCoord.w ) );
    }
    """
  depthWrite: false

mesh = new THREE.ParticleSystem(geometry, material)
mesh.position.x = 0
mesh.position.y = 0
scene.add mesh


animate = ->
  requestAnimationFrame animate
  render()

render = ->
  mesh.rotation.x += 0.01
  mesh.rotation.y += 0.02
  renderer.render scene, camera

gui = new DAT.GUI()
gui.add(material.uniforms.nearClipping, "value").name("nearClipping").min(1).max(10000).step 1.0
gui.add(material.uniforms.farClipping, "value").name("farClipping").min(1).max(10000).step 1.0
gui.add(material.uniforms.pointSize, "value").name("pointSize").min(1).max(10).step 1.0
gui.add(material.uniforms.zOffset, "value").name("zOffset").min(0).max(4000).step 1.0
gui.close()


renderer = new THREE.WebGLRenderer()
width = 600 # window.innerWidth
height = 400 # window.innerHeight
renderer.setSize width, height
$("#container").append renderer.domElement
mouse = new THREE.Vector3(0, 0, 1)

onDocumentMouseMove = (event) ->
  mouse.x = (event.clientX - width / 2) * 8
  mouse.y = (event.clientY - height / 2) * 8

container.addEventListener "mousemove", onDocumentMouseMove, false

animate = ->
  requestAnimationFrame animate
  render()
  stats.update()

render = ->
  camera.position.x += (mouse.x - camera.position.x) * 0.05
  camera.position.y += (-mouse.y - camera.position.y) * 0.05
  camera.lookAt center
  renderer.render scene, camera

animate()

