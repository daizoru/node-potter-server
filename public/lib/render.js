// Generated by CoffeeScript 1.3.3
(function() {
  var HEIGHT, WIDTH, animate, attributes, camera, center, controls, init, mouse, object, onDocumentMouseMove, onWindowResize, render, renderer, scene, stats, uniforms, vc1;

  renderer = void 0;

  scene = void 0;

  camera = void 0;

  stats = void 0;

  object = void 0;

  uniforms = void 0;

  controls = void 0;

  attributes = void 0;

  vc1 = void 0;

  mouse = void 0;

  center = new THREE.Vector3();

  center.z = -2;

  WIDTH = window.innerWidth;

  HEIGHT = window.innerHeight;

  init = function() {
    var container, dummyMaterial, geometry, gui, m, plane, planeMaterial, radius, scaling, shaderMaterial, v, values_color, values_size, vertex, vertices, x, y, z, _i, _j, _k;
    camera = new THREE.PerspectiveCamera(40, WIDTH / HEIGHT, 1, 1000);
    camera.position.z = 500;
    scene = new THREE.Scene();
    scene.add(camera);
    attributes = {
      size: {
        type: "f",
        value: []
      },
      ca: {
        type: "c",
        value: []
      }
    };
    uniforms = {
      cell_size: {
        type: "f",
        value: 80.0
      },
      amplitude: {
        type: "f",
        value: 1.0
      },
      color: {
        type: "c",
        value: new THREE.Color(0xffffff)
      },
      texture: {
        type: "t",
        value: 0,
        texture: THREE.ImageUtils.loadTexture("textures/sprites/ball.png")
      }
    };
    uniforms.texture.texture.wrapS = uniforms.texture.texture.wrapT = THREE.RepeatWrapping;
    shaderMaterial = new THREE.ShaderMaterial({
      uniforms: uniforms,
      attributes: attributes,
      vertexShader: document.getElementById("vertexshader").textContent,
      fragmentShader: document.getElementById("fragmentshader").textContent
    });
    scaling = 12;
    geometry = new THREE.Geometry();
    for (x = _i = -10; _i <= 10; x = ++_i) {
      for (y = _j = -10; _j <= 10; y = ++_j) {
        for (z = _k = -10; _k <= 10; z = ++_k) {
          vertex = new THREE.Vector3();
          vertex.x = x;
          vertex.y = y;
          vertex.z = z;
          vertex.multiplyScalar(scaling);
          geometry.vertices.push(vertex);
        }
      }
    }
    vc1 = geometry.vertices.length;
    m = void 0;
    dummyMaterial = new THREE.MeshFaceMaterial();
    radius = 200;
    object = new THREE.ParticleSystem(geometry, shaderMaterial);
    object.dynamic = true;
    vertices = object.geometry.vertices;
    values_size = attributes.size.value;
    values_color = attributes.ca.value;
    v = 0;
    while (v < vertices.length) {
      values_size[v] = 80;
      values_color[v] = new THREE.Color(0xffffff);
      values_color[v].setHSV(0.4 + 0.1 * (v / vc1), 0.99, 1.0);
      v++;
    }
    console.log(vertices.length);
    scene.add(object);
    planeMaterial = new THREE.MeshBasicMaterial({
      color: 0x020202,
      opacity: 0.15,
      transparent: true,
      wireframe: true
    });
    plane = new THREE.Mesh(new THREE.PlaneGeometry(300, 300, 16, 16), planeMaterial);
    plane.visible = true;
    scene.add(plane);
    renderer = new THREE.WebGLRenderer({
      clearColor: 0xffffff,
      clearAlpha: 1,
      antialias: true
    });
    renderer.setSize(WIDTH, HEIGHT);
    container = document.getElementById("container");
    container.appendChild(renderer.domElement);
    stats = new Stats();
    stats.domElement.style.position = "absolute";
    stats.domElement.style.top = "0px";
    container.appendChild(stats.domElement);
    gui = new DAT.GUI();
    gui.add(uniforms.cell_size, 'value').name('cell_size').min(40).max(180).step(0.5);
    gui.close();
    mouse = new THREE.Vector3(0, 0, 1);
    document.addEventListener('mousemove', onDocumentMouseMove, false);
    return window.addEventListener("resize", onWindowResize, false);
  };

  onWindowResize = function() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    return renderer.setSize(window.innerWidth, window.innerHeight);
  };

  onDocumentMouseMove = function(event) {
    mouse.x = event.clientX - window.innerWidth / 2;
    return mouse.y = event.clientY - window.innerHeight / 2;
  };

  animate = function() {
    requestAnimationFrame(animate);
    render();
    return stats.update();
  };

  render = function() {
    var i;
    camera.position.x += (mouse.x - camera.position.x) * 0.10;
    camera.position.y += (-mouse.y - camera.position.y) * 0.10;
    camera.lookAt(center);
    i = 0;
    while (i < attributes.size.value.length) {
      attributes.size.value[i] = uniforms.cell_size.value;
      i++;
    }
    attributes.size.needsUpdate = true;
    return renderer.render(scene, camera);
  };

  if (!Detector.webgl) {
    Detector.addGetWebGLMessage();
  }

  init();

  animate();

}).call(this);