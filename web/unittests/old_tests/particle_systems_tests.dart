library particlesLibtests;

import 'dart:html';
//import 'dart:math' as math;

import 'package:ranger/ranger.dart' as Ranger;
//import 'package:tweenengine/tweenengine.dart' as Tween;

import 'scenes_and_nodes.dart';

InputElement _nodeTagElement;
Element viewMouseElement;
Element nodePosElement;
Element localPosElement;
int maxParticles = 500;

Ranger.Scene particleSystemsTest(Ranger.Application engine) {
  _nodeTagElement = querySelector("#nodeTag");

  Ranger.Scene scene = _buildScene();
  
  return scene;
}

Ranger.Scene _buildScene() {
  //---------------------------------------------------------------
  // Scene
  //---------------------------------------------------------------
  //---------------------------------------------------------------
  // Simple color layer
  //---------------------------------------------------------------
  TestLayer layer = new TestLayer.withColor(Ranger.color4IFromHex("#eeeebb"));

  BasicScene scene = new BasicScene.withPrimary(layer, 10, 2010);

  return scene;
}

class TestLayer extends Ranger.BackgroundLayer {

  Ranger.ParticleSystem ps;
  Ranger.ParticleActivation pactivation;
  
  bool _turnCW = false;
  bool _turnCCW = false;
  bool _fireParticle = false;
  bool _continuous = false;
  
  TestLayer() {
    viewMouseElement = querySelector("#viewMouse");
    nodePosElement = querySelector("#nodePos");
    localPosElement = querySelector("#localPos");
  }
  
  factory TestLayer.withColor([Ranger.Color4<int> color, int width, int height]) {
    TestLayer layer = new TestLayer();
    layer.init(width, height);
    layer.color = color;
    layer.transparentBackground = false;
    return layer;
  }
  
  @override
  void update(double dt) {
    if (!(_turnCW && _turnCCW)) {
      if (_turnCW) {
        double angle = ps.particleActivation.angleDirection;
        angle -= 5.0;
        ps.particleActivation.angleDirection = angle;
      }
      else if (_turnCCW) {
        double angle = ps.particleActivation.angleDirection;
        angle += 5.0;
        ps.particleActivation.angleDirection = angle;
      }
    }
    
    if (_fireParticle || _continuous) {
      _fireParticle = false;
      if (_continuous)
        ps.activateByStyle(Ranger.ParticleActivation.OMNI_DIRECTIONAL);
      else
        ps.activateByStyle(Ranger.ParticleActivation.VARIANCE_DIRECTIONAL);
    }
    
  }
  
  @override
  void onEnter() {
    enableKeyboard = true;
    super.onEnter();
    
    //---------------------------------------------------------------
    // Basic grid
    //---------------------------------------------------------------
    Ranger.Size<double> size = Ranger.Application.instance.designSize;
    GridNode grid = new GridNode.withDimensions(size.width, size.height, false);
    addChild(grid, 0, 99);

    //---------------------------------------------------------------
    // A box.
    //---------------------------------------------------------------
    SquareNode baseSystemN = new SquareNode();
    baseSystemN.solid = true;
    baseSystemN.outlined = true;
    baseSystemN.size = 100.0;
    baseSystemN.center();
    baseSystemN.setPosition(100.0, 100.0);
    addChild(baseSystemN, 10, 101);

    //---------------------------------------------------------------
    // A point "inside" of the box for reference and comparison.
    //---------------------------------------------------------------
    NodePoint boxPointNode = new NodePoint();
    boxPointNode.setPosition(50.0, 0.0);
    boxPointNode.color = Ranger.Color3IBlue;
    boxPointNode.uniformScale = 3.0;
    baseSystemN.addChild(boxPointNode, 100, 102);

    Ranger.Application app = Ranger.Application.instance;
    
    //---------------------------------------------------------------
    // Paricle system
    //---------------------------------------------------------------
    Ranger.BasicParticleSystem bps = new Ranger.BasicParticleSystem.initWith(maxParticles);
//    Ranger.ModerateParticleSystem bps = new Ranger.ModerateParticleSystem.initWith(maxParticles);
    bps.emissionRate = 5;
//    bps.durationEnabled = true;
//    bps.emitterDuration = 0.5;
//    bps.pauseFor = 1.0;
    
    ps = bps;
    ps.setPosition(600.0, 400.0);
    
    Ranger.ParticleSystemVisual visual = ps.emitterVisual;
    visual.size = 25.0;
    addChild(visual, 200, 5001);
    app.scheduler.scheduleTimingTarget(ps);
    
    //---------------------------------------------------------------
    // Paricle Activation
    //---------------------------------------------------------------
    ps.particleActivation = _configureForNutronStarActivation();
//    ps.particleActivation = _configureForExplosiveActivation();
//    ps.particleActivation = _configureForSparklerActivation();
//    ps.particleActivation = _configureForSimpleActivation();

    //---------------------------------------------------------------
    // Paricle Visual and Behavior
    //---------------------------------------------------------------
//    _universalParticleTest();
    _tweenParticleTest();
//    _simpleParticleTest();
    
    ps.active = true;
    
    scheduleUpdate();
  }

  // This is good for explode or sparkler. It very little exceleration.
  Ranger.ParticleActivation _configureForSparklerActivation() {
    Ranger.RandomValueParticleActivator pa = new Ranger.RandomValueParticleActivator();
    // They all live for the same amount of time.
    pa.lifespan.min = 1.0;
    pa.lifespan.max = 2.0;
    pa.lifespan.variance = 1.5;
    pa.lifespan.mean = 0.5;

    pa.activationData.velocity.setSpeedRange(0.1, 5.0);
    pa.activationData.velocity.limitMagnitude = false;
    pa.speed.min = pa.activationData.velocity.minMagnitude;
    pa.speed.max = pa.activationData.velocity.maxMagnitude;
    pa.speed.variance = 2.25;
    pa.speed.mean = 0.5;

    pa.delay.min = 0.0;
    pa.delay.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
//    pa.delay.max = 2.0;
//    pa.delay.variance = 1.0;
    
    pa.acceleration.min = 0.001;
    pa.acceleration.max = 0.005;
    pa.acceleration.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
    pa.acceleration.variance = 0.003;
    pa.acceleration.mean = 0.5;
//    pa.acceleration.duration = 2.5;
//    pa.acceleration.delay = 0.5;
//    pa.acceleration.delayValue = 0.001;
    
    pa.startScale.min = 5.0;
    pa.startScale.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
    pa.endScale.min = 10.0;
    pa.endScale.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
    
    pa.startColor.setWith(Ranger.Color4IOrange);
    pa.endColor.setWith(Ranger.Color4IBlue);
    return pa;
  }

  Ranger.ParticleActivation _configureForExplosiveActivation() {
    Ranger.RandomValueParticleActivator pa = new Ranger.RandomValueParticleActivator();
    // They all live for the same amount of time.
    pa.lifespan.min = 1.0;
    pa.lifespan.max = 3.0;
    pa.lifespan.variance = 1.5;
    pa.lifespan.mean = 0.5;

    pa.activationData.velocity.setSpeedRange(0.1, 2.0);
    pa.activationData.velocity.limitMagnitude = false;
    pa.speed.min = pa.activationData.velocity.minMagnitude;
    pa.speed.max = pa.activationData.velocity.maxMagnitude;
    pa.speed.variance = 1.25;
    pa.speed.mean = 0.5;

    pa.delay.min = 0.0;
    pa.delay.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
//    pa.delay.max = 2.0;
//    pa.delay.variance = 1.0;
    
    pa.acceleration.min = 0.01;
    pa.acceleration.max = 0.25;
//    pa.acceleration.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
    pa.acceleration.variance = 0.25;
    pa.acceleration.mean = 0.5;
    //pa.acceleration.duration = 0.5;
    //pa.acceleration.delay = 0.5;
    //pa.acceleration.delayValue = 0.001;
    
    pa.startScale.min = 5.0;
    pa.startScale.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
    pa.endScale.min = 10.0;
    pa.endScale.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
    
    pa.startColor.setWith(Ranger.Color4IOrange);
    pa.endColor.setWith(Ranger.Color4IBlue);
    return pa;
  }

  Ranger.ParticleActivation _configureForNutronStarActivation() {
    Ranger.RandomValueParticleActivator pa = new Ranger.RandomValueParticleActivator();
    // They all live for the same amount of time.
    pa.lifespan.min = 2.0;
    pa.lifespan.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
//    pa.lifespan.max = 3.0;
//    pa.lifespan.variance = 1.0;
    //pa.lifespan.mean = 1.0;

    pa.activationData.velocity.setSpeedRange(0.1, 1.0);
    pa.activationData.velocity.limitMagnitude = false;
    pa.speed.min = pa.activationData.velocity.minMagnitude;
    pa.speed.max = pa.activationData.velocity.maxMagnitude;
//    pa.speed.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
    pa.speed.variance = 0.5;
    pa.speed.mean = 0.5;

//    pa.delay.min = 1.0;
//    pa.delay.max = 2.0;
//    pa.delay.variance = 1.0;
    
    pa.acceleration.min = 0.001;
    pa.acceleration.max = 0.003;
//    pa.acceleration.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
    pa.acceleration.variance = 0.002;
    pa.acceleration.mean = 0.5;
    pa.acceleration.duration = 1.0;
    pa.acceleration.delay = 0.5;
    pa.acceleration.delayValue = 0.01;
    
    pa.startScale.min = 5.0;
    pa.startScale.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
    pa.endScale.min = 10.0;
    pa.endScale.max = 15.0;
    
    //pa.endScale.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
    
    pa.startColor.setWith(Ranger.Color4IOrange);
    pa.endColor.setWith(Ranger.Color4IBlue);
    return pa;
  }
  
  Ranger.ParticleActivation _configureForSimpleActivation() {
    Ranger.SimpleParticleActivator pa = new Ranger.SimpleParticleActivator();
    pa.activationData.lifespan = 3.0;
    pa.activationData.speed = 2.0;
    pa.activationData.startScale = 10.0;
    pa.activationData.rotationRate = 10.0;
    return pa;
  }
  
  void _simpleParticleTest() {
    SquareParticleNode protoVisual;
    Ranger.SimpleParticle prototype;

    protoVisual = new SquareParticleNode.init();
    protoVisual.tag = 8;
    protoVisual.visible = false;
    
    prototype = new Ranger.SimpleParticle.withNode(protoVisual);
    ps.addByPrototype(this, prototype, maxParticles);
    prototype.moveToPool();
  }

  void _positionalCloneParticleTest() {
    SquareNode protoVisual;
    Ranger.PositionalParticle prototype;
    
    protoVisual = new SquareNode();
    protoVisual.tag = 8;
    protoVisual.visible = false;
    protoVisual.uniformScale = 5.0;
    protoVisual.solid = true;
    protoVisual.outlined = false;
    protoVisual.drawOrder = 1000;
    protoVisual.fillColor = Ranger.Color4IRed.toString();
    
    prototype = new Ranger.PositionalParticle.withLifeAndNode(3.0, protoVisual);
    
    ps.addByPrototype(this, prototype, maxParticles);
    prototype.moveToPool();
  }
  
  void _tweenParticleTest() {
    SquareParticleNode protoVisual;
    Ranger.TweenParticle prototype;

    Ranger.Color4<int> orangeTo = new Ranger.Color4<int>.withRGBA(255, 127, 0, 255);

    protoVisual = new SquareParticleNode.initWithColorAndScale(Ranger.Color4IBlue, 1.0);
    protoVisual.tag = 8;
    protoVisual.visible = false;
    protoVisual.uniformScale = 10.0;
    
    prototype = new Ranger.TweenParticle.withNode(protoVisual);
    
    ps.addByPrototype(this, prototype, maxParticles);
    prototype.moveToPool();
  }

  void _universalParticleTest() {
    SquareParticleNode protoVisual;
    Ranger.UniversalParticle prototype;

    Ranger.Color4<int> orangeTo = new Ranger.Color4<int>.withRGBA(255, 127, 0, 255);

    protoVisual = new SquareParticleNode.initWithColorAndScale(Ranger.Color4IBlue, 1.0);
    protoVisual.tag = 8;
    protoVisual.visible = false;
    protoVisual.uniformScale = 10.0;
    
    prototype = new Ranger.UniversalParticle.withNode(protoVisual);
    prototype.initWithColor(orangeTo, Ranger.Color4IBlue);
    prototype.initWithRotation(0.0, 45.0, 10.0, Ranger.ParticleRotationBehavior.CONSTANT);
    prototype.initWithScale(5.0, 50.0);
    
    ps.addByPrototype(this, prototype, maxParticles);
    prototype.moveToPool();
  }

//  @override
//  bool onTouchsMoved(Ranger.MutableEvent event) {
//    Ranger.Application app = Ranger.Application.instance; 
//    _showViewMouse(event.mouse.offset.x, event.mouse.offset.y);
//    
//    Ranger.Vector2P wP = app.drawContext.mapViewToWorld(event.mouse.offset.x, event.mouse.offset.y);
//    _showNodePos(wP.v.x, wP.v.y);
//    wP.moveToPool();
//    
//    // Find the box node by Tag. Note you don't really want to do this
//    // on "moves" you really should cache the Tagged Node.
//    int nodeTage = int.parse(_nodeTagElement.value);
//
//    Ranger.BaseNode box = getChildByTag(nodeTage);
//    
//    if (box != null) {
//      Ranger.Vector2P nP = box.convertWorldToNodeSpace(wP.v);
//      _showLocalPos(nP.v.x, nP.v.y);
//      nP.moveToPool();
//    }
//    
//    return Ranger.TouchDelegate.CLAIMED;
//  }

  @override
  bool onKeyDown(KeyboardEvent event) {
    //print("key onKeyDown ${event.keyEvent.keyCode}");

    switch (event.keyCode) {
      case 83://a
        // CCW
        _turnCCW = true;
        return true;
      case 65://s
        // CW
        _turnCW = true;
        return true;
      case 70://f
        _fireParticle = true;
        break;
      case 69://e
        return true;
      case 67://c
        _continuous = !_continuous;
        return true;
    }
    
    return false;
  }

  @override
  bool onKeyUp(KeyboardEvent event) {
    //print("key onKeyUp ${event.keyEvent.keyCode}");
    switch (event.keyCode) {
      case 83://a
        // CCW
        _turnCCW = false;
        return true;
      case 65://s
        // CW
        _turnCW = false;
        return true;
      case 70://f
        _fireParticle = false;
        break;
      case 69://e
        return true;
    }
    
    return false;
  }

  @override
  bool onKeyPress(KeyboardEvent event) {
    //print("key press ${event.keyEvent.keyCode}");
    
    switch (event.keyCode) {
      case 101://e
        ps.explodeByStyle(Ranger.ParticleActivation.OMNI_DIRECTIONAL);
        return true;
    }
    
    return false;
  }
  
  void _showViewMouse(int x, int y) {
    viewMouseElement.text = "(${x}, ${y})";
  }

  void _showNodePos(double x, double y) {
    nodePosElement.text = "(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})";
  }

  void _showLocalPos(double x, double y) {
    localPosElement.text = "(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})";
  }


}