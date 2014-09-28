part of unittests;

/**
 * This test shows how to properly transform [Node]s.  
 */
class ParticleSystems2Layer extends Ranger.BackgroundLayer {
  CanvasGradient _gradient;

  Ranger.SpriteImage _home;
  
  String startColor;
  String endColor;
  
  Ranger.TextNode _title;
  
  Ranger.ParticleSystem _explode1PS;
  Ranger.ParticleSystem _explode2PS;
  Ranger.ParticleSystem _explode3PS;
  Ranger.ParticleSystem _starPS;

  double _explode1Delay = 3.0;
  double _explode1DelayCount = 2.0;

  double _explode2Delay = 3.0;
  double _explode2DelayCount = 3.0;

  double _explode3Delay = 3.0;
  double _explode3DelayCount = 3.0;
  
  ParticleSystems2Layer();
 
  factory ParticleSystems2Layer.basic([bool centered = true, int width, int height]) {
    ParticleSystems2Layer layer = new ParticleSystems2Layer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = false;
    return layer;
  }

  @override
  bool init([int width, int height]) {
    super.init(width, height);

    _home = new Ranger.SpriteImage.withElement(GameManager.instance.resources.home);

    _title = new Ranger.TextNode.initWith(Ranger.color4IFromHex("#425563"));

    Ranger.Application app = Ranger.Application.instance;

    UTE.Tween.registerAccessor(Ranger.TextNode, app.animations);

    _configure();
    
    return true;
  }
  
  @override
  void update(double dt) {
    _explode1DelayCount += dt;
    if (_explode1DelayCount > _explode1Delay) {
      // Trigger another particle if one is available.
      _explode1PS.explodeByStyle(Ranger.ParticleActivation.OMNI_DIRECTIONAL);
      _explode1DelayCount = 0.0;
    }
    _explode1PS.update(dt);

    _explode2DelayCount += dt;
    if (_explode2DelayCount > _explode2Delay) {
      // Trigger another particle if one is available.
      _explode2PS.explodeByStyle(Ranger.ParticleActivation.OMNI_DIRECTIONAL);
      _explode2DelayCount = 0.0;
    }
    _explode2PS.update(dt);

    _explode3DelayCount += dt;
    if (_explode3DelayCount > _explode3Delay) {
      // Trigger another particle if one is available.
      _explode3PS.explodeByStyle(Ranger.ParticleActivation.OMNI_DIRECTIONAL);
      _explode3DelayCount = 0.0;
    }
    _explode3PS.update(dt);

    _starPS.activateByStyle(Ranger.ParticleActivation.OMNI_DIRECTIONAL);
    _starPS.update(dt);
  }
  
  @override
  void onEnter() {
    enableMouse = true;
    
    super.onEnter();
    
    scheduleUpdate();
  }
  
  @override
  void onExit() {
    super.onExit();

    // We need to terminate any animations onExit so they don't conflict
    // on any subsequent onEnter
    Ranger.Application app = Ranger.Application.instance;
    // Stop previous animation so relative motion doesn't add up causing
    // the target to animate offscreen.
    app.animations.tweenMan.killTarget(_title, Ranger.TweenAnimation.TRANSLATE_Y);

    unScheduleUpdate();
  }

  @override
  bool onMouseDown(MouseEvent event) {
    Ranger.Application app = Ranger.Application.instance;
    Ranger.Vector2P nodeP = app.drawContext.mapViewToNode(_home, event.offset.x, event.offset.y);
    nodeP.moveToPool();

    if (_home.containsPoint(nodeP.v)) {
      app.sceneManager.popScene();
    }
    
    return true;
  }

  void _configure() {
    Ranger.Application app = Ranger.Application.instance;
    
    double hHeight = app.designSize.height / 2.0;
    double hWidth = app.designSize.width / 2.0;
    double hGap = hWidth - (hWidth * 0.25);
    double vGap = hHeight - (hHeight * 0.25);
    
    addChild(_home, 10, 120);
    _home.uniformScale = 5.0;
    _home.setPosition(hGap, vGap);

    //---------------------------------------------------------------
    // Create text nodes.
    //---------------------------------------------------------------
    double vDelta = -vGap * 2.0;
    _title.text = "Particle Systems 2";
    _title.setPosition(hGap - (hGap * 0.75), vDelta);
    _title.strokeColor = Ranger.Color4IWhite;
    _title.strokeWidth = 1.0;
    _title.uniformScale = 5.0;
    addChild(_title, 10, 222);

    //---------------------------------------------------------------
    // Begin animating text into view.
    //---------------------------------------------------------------
    UTE.Timeline seq = new UTE.Timeline.sequence();
    
    UTE.Tween mTw1 = app.animations.moveBy(
        _title, 
        2.5,
        vDelta.abs() / 2.5, 0.0,
        UTE.Cubic.OUT, Ranger.TweenAnimation.TRANSLATE_Y, null, false);
    
    seq..push(mTw1)
      ..start();

    // -----------------------------------------------------------------
    // Construct Particle systems
    // -----------------------------------------------------------------
    _configureLeftPS();
    _explode1PS.setPosition(-hGap + (hGap * 0.05), 0.0);

    _configureRingPS();
    _explode2PS.setPosition(0.0, 0.0);
    
    _configureMiddlePS();
    _starPS.setPosition(0.0, 0.0);

    _configureRightPS();
    _explode3PS.setPosition(hGap - (hGap * 0.05), 0.0);
  }
 
  void drawBackground(Ranger.DrawContext context) {
    if (!transparentBackground) {
      CanvasRenderingContext2D context2D = context.renderContext as CanvasRenderingContext2D;

      Ranger.Size<double> size = contentSize;
      context.save();

      if (_gradient == null) {
        _gradient = context2D.createLinearGradient(0.0, 0.0, 0.0, size.height);
        _gradient.addColorStop(1.0, startColor);
        _gradient.addColorStop(0.0, endColor);
      }

      context2D..fillStyle = _gradient
          ..fillRect(0.0, 0.0, size.width, size.height);
      
      Ranger.Application.instance.objectsDrawn++;
      
      context.restore();
    }
  }

  //---------------------------------------------------------------
  // Left particle system
  //---------------------------------------------------------------
  void _configureLeftPS() {
    Ranger.BasicParticleSystem explode1PS = new Ranger.BasicParticleSystem.initWith(200);
    
    Ranger.Color4<int> orangeAlpha = new Ranger.Color4<int>.withRGBA(255, 127, 0, 0);
    Ranger.RandomValueParticleActivator pa = _configureForSparklerExplosion2(Ranger.Color4IGreen, orangeAlpha);
    
    explode1PS.particleActivation = pa;
    
    _populateParticleSystemWithCircles(explode1PS);
    explode1PS.active = true;
    explode1PS.emissionRate = 5;
    
    _explode1PS = explode1PS;
  }

  // Explodes with an inner vapor like delay
  Ranger.ParticleActivation _configureForSparklerExplosion1(Ranger.Color4<int> fromColor, Ranger.Color4<int> toColor) {
    Ranger.RandomValueParticleActivator pa = new Ranger.RandomValueParticleActivator();
    pa.lifespan.min = 0.1;
    pa.lifespan.max = 3.0;
    pa.lifespan.variance = 1.0;
    
    pa.activationData.velocity.setSpeedRange(0.1, 3.0);
    pa.speed.min = pa.activationData.velocity.minMagnitude;
    pa.speed.max = pa.activationData.velocity.maxMagnitude;
    pa.speed.variance = (pa.speed.max - pa.speed.min) * 0.1;

    pa.acceleration.min = 0.001;
    pa.acceleration.max = 0.002;
    pa.acceleration.variance = (pa.acceleration.max - pa.acceleration.min) / 2.0;
    //pa.acceleration.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
   
    pa.startScale.min = 2.5;
    pa.startScale.max = 4.5;
    pa.startScale.variance = (pa.startScale.max - pa.startScale.min) / 2.0;
    
    pa.endScale.min = 10.0;
    pa.endScale.max = 20.5;
    pa.endScale.variance = (pa.endScale.max - pa.endScale.min) / 2.0;
    
    pa.startColor.setWith(fromColor);
    pa.endColor.setWith(toColor);
    return pa;
  }

  // Rapid expansion effect; a burst.
  Ranger.ParticleActivation _configureForSparklerExplosion2(Ranger.Color4<int> fromColor, Ranger.Color4<int> toColor) {
    Ranger.RandomValueParticleActivator pa = new Ranger.RandomValueParticleActivator();
    pa.lifespan.min = 0.1;
    pa.lifespan.max = 2.0;
    pa.lifespan.variance = 1.0;
    
    pa.activationData.velocity.setSpeedRange(0.1, 10.0);
    pa.activationData.velocity.limitMagnitude = false;
    pa.speed.min = pa.activationData.velocity.minMagnitude;
    pa.speed.max = pa.activationData.velocity.maxMagnitude;
    pa.speed.variance = 10.0;
    pa.speed.mean = 0.01;

    pa.acceleration.min = 0.1;
    pa.acceleration.max = 0.5;
    pa.acceleration.variance = 0.25;
    //pa.acceleration.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
   
    pa.startScale.min = 0.5;
    pa.startScale.max = 1.5;
    pa.startScale.variance = 0.75;
    
    pa.endScale.min = 3.0;
    pa.endScale.max = 6.5;
    pa.endScale.variance = 3.5;
    
    pa.startColor.setWith(fromColor);
    pa.endColor.setWith(toColor);
    return pa;
  }

  // slow explosition
  Ranger.ParticleActivation _configureForSparklerExplosion3(Ranger.Color4<int> fromColor, Ranger.Color4<int> toColor) {
    Ranger.RandomValueParticleActivator pa = new Ranger.RandomValueParticleActivator();
    pa.lifespan.min = 0.1;
    pa.lifespan.max = 5.0;
    pa.lifespan.variance = (pa.lifespan.max - pa.lifespan.min) / 2.0;
    
    pa.activationData.velocity.setSpeedRange(0.1, 2.0);
    pa.activationData.velocity.limitMagnitude = false;
    pa.speed.min = pa.activationData.velocity.minMagnitude;
    pa.speed.max = pa.activationData.velocity.maxMagnitude;
    pa.speed.variance = (pa.speed.max - pa.speed.min) / 2.0;

    pa.acceleration.min = 0.0001;
    pa.acceleration.max = 0.05;
    pa.acceleration.variance = (pa.acceleration.max - pa.acceleration.min) * 0.5;
   
    pa.startScale.min = 0.5;
    pa.startScale.max = 1.5;
    pa.startScale.variance = (pa.startScale.max - pa.startScale.min) / 2.0;
    
    pa.endScale.min = 30.0;
    pa.endScale.max = 40.0;
    pa.endScale.variance = (pa.endScale.max - pa.endScale.min) / 2.0;
    
    pa.startColor.setWith(fromColor);
    pa.endColor.setWith(toColor);
    return pa;
  }

  // Typical uniform explosition
  Ranger.ParticleActivation _configureForSparklerExplosion4(Ranger.Color4<int> fromColor, Ranger.Color4<int> toColor) {
    Ranger.RandomValueParticleActivator pa = new Ranger.RandomValueParticleActivator();
    pa.lifespan.min = 0.1;
    pa.lifespan.max = 2.0;
    pa.lifespan.variance = 1.0;
    
    pa.activationData.velocity.setSpeedRange(0.5, 6.0);
    pa.activationData.velocity.limitMagnitude = false;
    pa.speed.min = pa.activationData.velocity.minMagnitude;
    pa.speed.max = pa.activationData.velocity.maxMagnitude;
    pa.speed.variance = 3.0;
    pa.speed.mean = 0.5;

    pa.acceleration.min = 0.0001;
    pa.acceleration.max = 0.005;
    pa.acceleration.variance = 0.00025;
    pa.acceleration.mean = 0.1;
    //pa.acceleration.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
   
    pa.startScale.min = 0.5;
    pa.startScale.max = 1.5;
    pa.startScale.variance = 0.75;
    
    pa.endScale.min = 3.0;
    pa.endScale.max = 6.5;
    pa.endScale.variance = 3.5;
    
    pa.startColor.setWith(fromColor);
    pa.endColor.setWith(toColor);
    return pa;
  }

  //---------------------------------------------------------------
  // Middle particle system
  //---------------------------------------------------------------
  void _configureMiddlePS() {
    Ranger.BasicParticleSystem starPS = new Ranger.BasicParticleSystem.initWith(300);
    
    Ranger.Color4<int> redAlpha = new Ranger.Color4<int>.withRGBA(255, 0, 0, 0);
    Ranger.Color4<int> goldenYellowAlpha = new Ranger.Color4<int>.withRGBA(255, 200, 0, 255);
    
    Ranger.RandomValueParticleActivator pa = _configureForStarActivation(goldenYellowAlpha, redAlpha);
    
    starPS.particleActivation = pa;
    
    _populateParticleSystemWithCircles(starPS);
    starPS.active = true;
    starPS.emissionRate = 10;
    
    _starPS = starPS;
  }

  Ranger.ParticleActivation _configureForStarActivation(Ranger.Color4<int> fromColor, Ranger.Color4<int> toColor) {
    Ranger.RandomValueParticleActivator pa = new Ranger.RandomValueParticleActivator();
    pa.lifespan.min = 0.5;
    pa.lifespan.max = 4.0;
    pa.lifespan.variance = (pa.lifespan.max - pa.lifespan.min) / 2.0;
    
    pa.activationData.velocity.setSpeedRange(0.5, 1.0);
    //pa.activationData.velocity.limitMagnitude = false;
    pa.speed.min = pa.activationData.velocity.minMagnitude;
    pa.speed.max = pa.activationData.velocity.maxMagnitude;
    pa.speed.variance = 1.0;
    pa.speed.variance = (pa.speed.max - pa.speed.min) / 2.0;
    
    pa.acceleration.min = 0.01;
    pa.acceleration.max = 0.05;
    pa.acceleration.variance = (pa.acceleration.max - pa.acceleration.min) / 2.0;
//    pa.acceleration.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
   
    pa.startScale.min = 10.0;
    pa.startScale.max = 25.0;
    pa.startScale.variance = 0.5;
    
    pa.endScale.min = 1.0;
    pa.endScale.max = 2.5;
    pa.endScale.variance = 1.5;
    
    pa.startColor.setWith(fromColor);
    pa.endColor.setWith(toColor);
    return pa;
  }

  //---------------------------------------------------------------
  // Ring particle system
  //---------------------------------------------------------------
  void _configureRingPS() {
    Ranger.BasicParticleSystem explodePS = new Ranger.BasicParticleSystem.initWith(100);
    
    Ranger.Color4<int> redAlpha = new Ranger.Color4<int>.withRGBA(255, 0, 0, 0);
    Ranger.Color4<int> purpleAlpha = Ranger.color4IFromHex("#8031a7cc");

    Ranger.RandomValueParticleActivator pa = _configureForSparklerExplosion1(redAlpha, purpleAlpha);
    
    explodePS.particleActivation = pa;
    
    _populateParticleSystemWithSquares(explodePS);
    explodePS.active = true;
    explodePS.emissionRate = 3;
    
    _explode2PS = explodePS;
  }

  //---------------------------------------------------------------
  // Right particle system
  //---------------------------------------------------------------
  void _configureRightPS() {
    Ranger.BasicParticleSystem explodePS = new Ranger.BasicParticleSystem.initWith(200);
    
    Ranger.Color4<int> greenAlpha = new Ranger.Color4<int>.withRGBA(0, 255, 0, 0);
    Ranger.Color4<int> yellowAlpha = new Ranger.Color4<int>.withRGBA(255, 255, 0, 128);

    Ranger.RandomValueParticleActivator pa = _configureForSparklerExplosion3(greenAlpha, yellowAlpha);
    
    explodePS.particleActivation = pa;
    
    _populateParticleSystemWithSquares(explodePS);
    explodePS.active = true;
    explodePS.emissionRate = 3;
    
    _explode3PS = explodePS;
  }

  //---------------------------------------------------------------
  // Build particles
  //---------------------------------------------------------------
  void _populateParticleSystemWithCircles(Ranger.ParticleSystem ps) {
    // To populate a particle system we need prototypes to clone from.
    // Once the particle system has been built we can dispense with the
    // prototypes.
    
    // First we create a "prototype" visual which will be assigned to a
    // prototype particle.
    CircleParticleNode protoVisual = new CircleParticleNode.initWith(Ranger.Color4IWhite);
    protoVisual.tag = 8;
    protoVisual.visible = false;
    protoVisual.uniformScale = 1.0;
    
    // Next we create an actual particle and assign to it the prototype visual.
    // Together the particle system will clone this prototype particle along with its
    // visual (N) times.
    // Default values of 1.0 given because these values will determined when
    // the particle is launched. They are just place holder values for the
    // prototype.
    Ranger.UniversalParticle prototype = new Ranger.UniversalParticle.withNode(protoVisual);
    prototype.velocity.limitMagnitude = false;
    // These initial colors are often ignored in favor of what an Activator
    // will generate.
    prototype.initWithScale(1.0, 15.0);
    
    // Now we populate the particle system with "clones" of the prototype.
    // The particles will be emitted onto "this" layer.
    ps.addByPrototype(this, prototype);
    
    // The prototype is no longer relevant as it has been cloned. So
    // we move it back to the pool.
    protoVisual.moveToPool();
    prototype.moveToPool();
  }
  
  void _populateParticleSystemWithSquares(Ranger.ParticleSystem ps) {
    // To populate a particle system we need prototypes to clone from.
    // Once the particle system has been built we can dispense with the
    // prototypes.
    
    // First we create a "prototype" visual which will be assigned to a
    // prototype particle.
    SquareParticleNode protoVisual = new SquareParticleNode.basic();
    protoVisual.center();
    protoVisual.tag = 8;
    protoVisual.visible = false;
    protoVisual.uniformScale = 1.0;
    
    // Next we create an actual particle and assign to it the prototype visual.
    // Together the particle system will clone this prototype particle along with its
    // visual (N) times.
    // Default values of 1.0 given because these values will determined when
    // the particle is launched. They are just place holder values for the
    // prototype.
    Ranger.UniversalParticle prototype = new Ranger.UniversalParticle.withNode(protoVisual);
    prototype.velocity.limitMagnitude = false;
    // These initial colors are often ignored in favor of what an Activator
    // will generate.
    prototype.initWithScale(1.0, 15.0);
    
    // Now we populate the particle system with "clones" of the prototype.
    // The particles will be emitted onto "this" layer.
    ps.addByPrototype(this, prototype);
    
    // The prototype is no longer relevant as it has been cloned. So
    // we move it back to the pool.
    protoVisual.moveToPool();
    prototype.moveToPool();
  }
}
