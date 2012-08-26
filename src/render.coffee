renderer = undefined
scene = undefined
camera = undefined
stats = undefined
object = undefined
uniforms = undefined
controls = undefined
attributes = undefined
vc1 = undefined
mouse = undefined
center = new THREE.Vector3()
center.z = - 2
WIDTH = window.innerWidth
HEIGHT = window.innerHeight


init = ->

  camera = new THREE.PerspectiveCamera(40, WIDTH / HEIGHT, 1, 1000)
  camera.position.z = 500


  # controls = new THREE.TrackballControls( camera )

  # controls.rotateSpeed = 1.0
  # controls.zoomSpeed = 1.2
  # controls.panSpeed = 0.8

  # controls.noZoom = false
  # controls.noPan = false

  # controls.staticMoving = yes
  # controls.dynamicDampingFactor = 0.3

  # controls.keys = [ 65, 83, 68 ]

  # controls.addEventListener( 'change', render )

  scene = new THREE.Scene()
  scene.add camera
  attributes =
    size:
      type: "f"
      value: []

    ca:
      type: "c"
      value: []

  uniforms =
    cell_size:
      type: "f"
      value: 80.0

    amplitude:
      type: "f"
      value: 1.0

    color:
      type: "c"
      value: new THREE.Color(0xffffff)

    texture:
      type: "t"
      value: 0
      texture: THREE.ImageUtils.loadTexture "textures/sprites/ball.png"

  uniforms.texture.texture.wrapS = uniforms.texture.texture.wrapT = THREE.RepeatWrapping
  shaderMaterial = new THREE.ShaderMaterial
    uniforms: uniforms
    attributes: attributes
    vertexShader: document.getElementById("vertexshader").textContent
    fragmentShader: document.getElementById("fragmentshader").textContent

  scaling = 12
  geometry = new THREE.Geometry()
  for x in [-10..10]
    for y in [-10..10]
      for z in [-10..10]
        vertex = new THREE.Vector3()
        vertex.x = x
        vertex.y = y
        vertex.z = z
        vertex.multiplyScalar scaling
        geometry.vertices.push vertex

  vc1 = geometry.vertices.length
  m = undefined
  dummyMaterial = new THREE.MeshFaceMaterial()
  radius = 200
  
  # particle system
  object = new THREE.ParticleSystem geometry, shaderMaterial
  object.dynamic = true
  
  # custom attributes
  vertices = object.geometry.vertices
  values_size = attributes.size.value
  values_color = attributes.ca.value
  v = 0

  while v < vertices.length
    values_size[v] = 80
    values_color[v] = new THREE.Color 0xffffff
    values_color[v].setHSV 0.4 + 0.1 * (v / vc1), 0.99, 1.0
    v++
  
  console.log( vertices.length )
  scene.add object

  planeMaterial = new THREE.MeshBasicMaterial
    color: 0x020202
    opacity: 0.15
    transparent: yes
    wireframe: yes
  plane = new THREE.Mesh(new THREE.PlaneGeometry( 300, 300, 16, 16 ), planeMaterial)
  plane.visible = yes
  scene.add plane

  renderer = new THREE.WebGLRenderer
    clearColor: 0xffffff
    clearAlpha: 1
    antialias: yes


  #renderer.shadowMapEnabled = true
  #renderer.shadowMapSoft = true

  renderer.setSize WIDTH, HEIGHT
  container = document.getElementById "container"
  container.appendChild renderer.domElement
  stats = new Stats()
  stats.domElement.style.position = "absolute"
  stats.domElement.style.top = "0px"
  container.appendChild stats.domElement
  
  gui = new DAT.GUI()
  gui.add( uniforms.cell_size, 'value' ).name( 'cell_size' ).min( 40 ).max( 180 ).step( 0.5 )
  gui.close()
  mouse = new THREE.Vector3( 0, 0, 1 )

  document.addEventListener 'mousemove', onDocumentMouseMove, false
  #
  window.addEventListener "resize", onWindowResize, false
onWindowResize = ->
  camera.aspect = window.innerWidth / window.innerHeight
  camera.updateProjectionMatrix()
  renderer.setSize window.innerWidth, window.innerHeight
onDocumentMouseMove = ( event ) ->
  mouse.x = event.clientX - window.innerWidth / 2 
  mouse.y = event.clientY - window.innerHeight / 2 

animate = ->
  requestAnimationFrame animate
  render()
  stats.update()

render = ->
  camera.position.x += ( mouse.x - camera.position.x ) * 0.10
  camera.position.y += ( - mouse.y - camera.position.y ) * 0.10
  camera.lookAt center

  #object.rotation.y = object.rotation.z = 0.02 * time
  i = 0

  while i < attributes.size.value.length
    attributes.size.value[i] = uniforms.cell_size.value
    i++
  attributes.size.needsUpdate = true
  renderer.render scene, camera
  #controls.update()
Detector.addGetWebGLMessage()  unless Detector.webgl

init()
animate()