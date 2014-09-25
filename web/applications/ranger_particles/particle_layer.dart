import 'dart:html' as Html;

import 'package:ranger/ranger.dart' as Ranger;
import 'package:vector_math/vector_math.dart';

import 'custom_particle.dart';

/*
 * We need to be able to activate new particles with different parms.
 * For example, If the begining color changes then all newly emitted
 * particles use that color.
 * Hence, when a particle is being launched we set the start color based on
 * the current start color.
 */
class ParticleLayer extends Ranger.BackgroundLayer {
  Ranger.ModerateParticleSystem ps;
  Ranger.ParticleActivation pactivation;
  
  bool fireParticle = false;
  bool _turnCW = false;
  bool _turnCCW = false;

  bool _ignoreKeyInput = false;
  
  bool constantFire = true;
  
  int emissionType = 0;
  
  double sweepRate = 1.0;
  
  ParticleLayer() {
  }

  factory ParticleLayer.withColor(Ranger.Color4<int> color, [bool centered = true, int width, int height]) {
    ParticleLayer layer = new ParticleLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.color = color;
    layer.transparentBackground = false;
    return layer;
  }

  set ignoreKeyInput(bool v) => _ignoreKeyInput = v;
  //Map get configuration => ps.toMap();
  
  void reconfigure() {
    switch(emissionType) {
      case 0:
        break;
      case 1:
        break;
      case 2:
        break;
      case 3:
        break;
      case 4:
        // ping-pong
        //ps.angleDirection = ps.sweepAngle = -90.0;
        break;
      case 5:
        // radial sweep
        //ps.sweepAngleRate = 1.0;
        break;
    }

  }
  @override
  void onEnter() {
    super.onEnter();
    Ranger.Application app = Ranger.Application.instance;

    //---------------------------------------------------------------
    // Paricle system
    //---------------------------------------------------------------
    int maxParticles = 500;
    pactivation = new Ranger.RandomValueParticleActivator();
    
    ps = new Ranger.ModerateParticleSystem.initWith(maxParticles);
    //ps.preActivateCallback = _launchingParticle;
    
    ps.setPosition(0.0, 0.0);
    ps.active = true;
    
    Ranger.ParticleSystemVisual visual = ps.emitterVisual;
    visual.size = 25.0;
    addChild(visual, 200, 5001);
    
    ps.particleActivation = _configureForSparklerActivation();

//    _colorSquareRotationalParticleTest(1000);
    _tweenParticleTest(maxParticles);
    
    app.scheduler.scheduleTimingTarget(ps);

    //    LeafPoint circle = new LeafPoint();
    //    circle.setPosition(0.0, 0.0);
    //    circle.color = Ranger.Color3IBlue;
    //    circle.uniformScale = 10.0;
    //    addChild(circle, 100, 109);
    //
    //    circle = new LeafPoint();
    //    circle.setPosition(400.0/2, 600.0/2);
    //    circle.color = Ranger.Color3IRed;
    //    circle.uniformScale = 10.0;
    //    addChild(circle, 100, 110);

    scheduleUpdate();
    app.sceneIsReady();
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

  // Called just before a particle is being activated.
//  void _launchingParticle(Ranger.Particle p) {
//    Ranger.ColorRotationParticle crp = p as Ranger.ColorRotationParticle;
//    if (crp != null) {
//      crp.toColor.r = ps.endColor.r;
//      crp.toColor.g = ps.endColor.g;
//      crp.toColor.b = ps.endColor.b;
//      
//      if (crp.node is Ranger.Color4Mixin) {
//        Ranger.Color4Mixin cb = crp.node as Ranger.Color4Mixin;
//        cb.initWithColor(ps.startColor);
//      }
//    }
//  }
  
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
   
    _activate(dt);
  }

  void _activate(double dt) {
    // We only activate particles under the following conditions.
    // Continuous or manually triggering a single particle or
    // Duration is enabled and the emission duration hasn't expired.
    if (constantFire || fireParticle || (ps.durationEnabled && !ps.durationExpired)) {
      fireParticle = false;
      
      ps.activateByStyle(emissionType, dt);
    }
  }
  
  @override
  bool onKeyPress(Html.KeyboardEvent event) {
    //print("key press ${event.keyCode}");
    
    if (_ignoreKeyInput)
      return false;

    switch (event.keyCode) {
      case 101://e
        explode();
        return true;
    }

    return false;
  }

  @override
  bool onKeyDown(Html.KeyboardEvent event) {
    if (_ignoreKeyInput)
      return false;//Ranger.KeyboardDelegate.PASS;
    //print("key onKeyDown ${event.keyEvent.keyCode}");

    switch (event.keyCode) {
      case 82://r
        // reset
        ps.particleActivation.angleDirection = -90.0;
        return true;
      case 83://a
        // CW
        _turnCW = true;
        return true;
      case 65://s
        // CCW
        _turnCCW = true;
        return true;
      case 70://f
        fireParticle = true;
        break;
      case 69://e
        return true;
    }
    
    return false;
  }

  @override
  bool onKeyUp(Html.KeyboardEvent event) {
    if (_ignoreKeyInput)
      return false;
    
    //print("key onKeyUp ${event.keyEvent.keyCode}");
    switch (event.keyCode) {
      case 83://a
        // CW
        _turnCW = false;
        return true;
      case 65://s
        // CCW
        _turnCCW = false;
        return true;
      case 70://f
        fireParticle = false;
        break;
      case 69://e
        return true;
    }
    
    return false;
  }

  void explode() {
    ps.explodeByStyle(emissionType);
  }
  
  void _tweenParticleTest(int particles) {
    SquareParticleNode protoVisual;
    CustomParticle prototype;

    protoVisual = new SquareParticleNode.initWithColorAndScale(Ranger.Color4IBlue, 1.0);
    protoVisual.tag = 8;
    protoVisual.visible = false;
    protoVisual.uniformScale = 10.0;
    
    prototype = new CustomParticle.withNode(protoVisual);
    
    ps.addByPrototype(this, prototype, particles);
    prototype.moveToPool();
  }


//  void _colorSquareRotationalParticleTest(int particles) {
//    SquareParticleNode particlePrototypeVisual;
//    Ranger.ColorRotationParticle prototype;
//
//    Ranger.Color4<int> orangeTo = new Ranger.Color4<int>.withRGBA(255, 127, 0,
//        128);
//
//    particlePrototypeVisual = new SquareParticleNode.initWithColorAndScale(
//        Ranger.Color4IBlue, 1.0);
//    particlePrototypeVisual.tag = 8;
//    particlePrototypeVisual.drawOrder = 1000;
//    particlePrototypeVisual.visible = false;
//    particlePrototypeVisual.uniformScale = 20.0;
//
//    prototype = new Ranger.ColorRotationParticle.withLifeAndNode(3.0,
//        particlePrototypeVisual, orangeTo, 0.0);
//
//    ps.addByPrototype(this, prototype, particles);
//    prototype.moveToPool();
//  }

}

class LeafPoint extends Ranger.Node {
  Vector2 point = new Vector2.zero();
  Ranger.Color3<int> color = Ranger.Color3IWhite;
  // This is for visual scaling. Scaling a point doesn't really mean
  // anything transform wise. But it can't be visually hard to see the
  // point. So drawScale helps with visually seeing the point without
  // polluting the transform space with a meaningless scale.
  int drawScale = 1;

  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  LeafPoint() {
    init();
  }

  LeafPoint._();
  factory LeafPoint.pooled() {
    LeafPoint poolable = new Ranger.Poolable.of(LeafPoint, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  static LeafPoint _createPoolable() => new LeafPoint._();

  @override
  bool init() {
    if (super.init()) {
      return true;
    }

    return false;
  }

  LeafPoint clone() {
    LeafPoint poolable = new LeafPoint.pooled();
    if (poolable.initWith(this)) {
      poolable.init();
      poolable.point.setFrom(point);
      poolable.color.r = color.r;
      poolable.color.g = color.g;
      poolable.color.b = color.b;
      poolable.drawScale = drawScale;
      return poolable;
    }

    return null;
  }


  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  void release() {
    super.release();
    color.moveToPool();
  }

  @override
  void draw(Ranger.DrawContext context) {
    context.save();
    context.fillColor = color.toString();
    context.drawPoint(point, drawScale);
    context.restore();
  }
}

// This node is a custom rendering node specific to Canvas2D
class SquareParticleNode extends Ranger.Node with Ranger.Color4Mixin {
  Vector2 localPosition = new Vector2.zero();

  Ranger.MutableRectangle<double> rect = new Ranger.MutableRectangle<double>(
      0.0, 0.0, 0.0, 0.0);

  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  factory SquareParticleNode.initWithColorAndScale(Ranger.Color4<int>
      from, [double fromScale = 1.0]) {
    SquareParticleNode poolable = new SquareParticleNode.pooled();
    if (poolable.init()) {
      poolable.initWithColor(from);
      poolable.initWithUniformScale(poolable, fromScale);
      poolable.size = 1.0;
      poolable.center();
      return poolable;
    }
    return null;
  }

  SquareParticleNode._();

  factory SquareParticleNode.pooled() {
    SquareParticleNode poolable = new Ranger.Poolable.of(SquareParticleNode, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  static SquareParticleNode _createPoolable() => new SquareParticleNode._();

  SquareParticleNode clone() {
    //    SquareParticleNode poolable = new SquareParticleNode.initWithColorAndScale(initialColor, uniformScale);
    //    poolable.localPosition.setFrom(localPosition);
    //    return poolable;
    SquareParticleNode poolable = new SquareParticleNode.pooled();

    if (poolable.initWith(this)) {
      poolable.initWithColor(initialColor);
      poolable.initWithUniformScale(poolable, uniformScale);
      poolable.size = 1.0;
      poolable.center();
      return poolable;
    }

    return null;
  }

  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  void center() {
    rect.left = rect.left - (rect.width / 2.0);
    rect.bottom = rect.bottom - (rect.height / 2.0);
  }

  set size(double s) {
    rect.width = s;
    rect.height = s;
  }

  @override
  set dirty(bool dirty) {
    super.dirty = dirty;
  }

  @override
  void draw(Ranger.DrawContext context) {
    context.save();
    //    CanvasRenderingContext2D render = context.renderContext;
    //
    //    render.fillStyle = color.toString();
    //    render.rect(rect.bottom, rect.left, rect.width, rect.height);
    //    render.fill();

    //    render..strokeStyle = drawColor
    //             ..stroke();
    context.fillColor = color.toString();

    context.drawRect(rect.left, rect.bottom, rect.width, rect.height);
    context.restore();
  }
}
