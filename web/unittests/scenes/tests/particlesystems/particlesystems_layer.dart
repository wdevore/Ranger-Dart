part of unittests;

/**
 * This test shows how to properly transform [Node]s.  
 */
class ParticleSystemsLayer extends Ranger.BackgroundLayer {
  CanvasGradient _gradient;

  Ranger.SpriteImage _home;
  
  String startColor;
  String endColor;
  
  Ranger.TextNode _title;
  
  Ranger.ParticleSystem _sparklerPS;
  Ranger.ParticleSystem _hosePS;
  Ranger.ParticleSystem _spiralPS;

  ParticleSystemsLayer();
 
  factory ParticleSystemsLayer.basic([bool centered = true, int width, int height]) {
    ParticleSystemsLayer layer = new ParticleSystemsLayer();
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
    // Trigger another particle if one is available.
    _sparklerPS.activateByStyle(Ranger.ParticleActivation.OMNI_DIRECTIONAL);
    _sparklerPS.update(dt);

    _hosePS.activateByStyle(Ranger.ParticleActivation.DRIFT_DIRECTIONAL);
    _hosePS.update(dt);

    _spiralPS.activateByStyle(Ranger.ParticleActivation.RADIALSWEEP_DIRECTIONAL);
    _spiralPS.update(dt);
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
    _title.text = "Particle Systems 1";
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
    // Construct sparkler Particle system
    // -----------------------------------------------------------------
    _configureLeftPS();
    _sparklerPS.setPosition(-hGap + (hGap * 0.05), 0.0);

    // -----------------------------------------------------------------
    // Construct hose Particle system
    // -----------------------------------------------------------------
    _configureMiddlePS();
    _hosePS.setPosition(0.0, 0.0);

    // -----------------------------------------------------------------
    // Construct spiral Particle system
    // -----------------------------------------------------------------
    _configureRightPS();
    _spiralPS.setPosition(hGap - (hGap * 0.05), 0.0);
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
    Ranger.BasicParticleSystem sparklerPS = new Ranger.BasicParticleSystem.initWith(200);
    
    Ranger.RandomValueParticleActivator pa = _configureForSparklerActivation(Ranger.Color4IGreen, Ranger.Color4IOrange);
    
    sparklerPS.particleActivation = pa;
    
    _populateParticleSystemWithCircles(sparklerPS);
    sparklerPS.active = true;
    sparklerPS.emissionRate = 3;
    
    _sparklerPS = sparklerPS;
  }

  Ranger.ParticleActivation _configureForSparklerActivation(Ranger.Color4<int> fromColor, Ranger.Color4<int> toColor) {
    Ranger.RandomValueParticleActivator pa = new Ranger.RandomValueParticleActivator();
    // They all live for the same amount of time.
    pa.lifespan.min = 0.1;
    pa.lifespan.max = 1.0;
    pa.lifespan.variance = 0.5;
    
    pa.activationData.velocity.setSpeedRange(1.0, 3.0);
    pa.activationData.velocity.limitMagnitude = false;
    pa.speed.min = pa.activationData.velocity.minMagnitude;
    pa.speed.max = pa.activationData.velocity.maxMagnitude;
    pa.speed.variance = 1.0;

    pa.acceleration.min = 0.0;
    pa.acceleration.max = 0.0;
    pa.acceleration.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
   
    pa.startScale.min = 1.0;
    pa.startScale.max = 1.5;
    pa.startScale.variance = 0.5;
    
    pa.endScale.min = 6.0;
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
    Ranger.BasicParticleSystem hosePS = new Ranger.BasicParticleSystem.initWith(200);
    
    Ranger.RandomValueParticleActivator pa = _configureForHoseActivation(Ranger.Color4IWhite, Ranger.color4IFromHex("#693f23"));
    pa.angleDirection = 0.0;
    
    hosePS.particleActivation = pa;
    
    _populateParticleSystemWithCircles(hosePS);
    hosePS.active = true;
    hosePS.emissionRate = 3;
    
    _hosePS = hosePS;
  }

  Ranger.ParticleActivation _configureForHoseActivation(Ranger.Color4<int> fromColor, Ranger.Color4<int> toColor) {
    Ranger.RandomValueParticleActivator pa = new Ranger.RandomValueParticleActivator();
    // They all live for the same amount of time.
    pa.lifespan.min = 0.1;
    pa.lifespan.max = 1.0;
    pa.lifespan.variance = 0.5;
    
    pa.activationData.velocity.setSpeedRange(1.0, 3.0);
    pa.activationData.velocity.limitMagnitude = false;
    pa.speed.min = pa.activationData.velocity.minMagnitude;
    pa.speed.max = pa.activationData.velocity.maxMagnitude;
    pa.speed.variance = 1.0;

    pa.acceleration.min = 0.0;
    pa.acceleration.max = 0.0;
    pa.acceleration.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
   
    pa.startScale.min = 1.0;
    pa.startScale.max = 1.5;
    pa.startScale.variance = 0.5;
    
    pa.endScale.min = 6.0;
    pa.endScale.max = 6.5;
    pa.endScale.variance = 3.5;
    
    pa.startColor.setWith(fromColor);
    pa.endColor.setWith(toColor);
    return pa;
  }

  //---------------------------------------------------------------
  // Right particle system
  //---------------------------------------------------------------
  void _configureRightPS() {
    Ranger.BasicParticleSystem spiralPS = new Ranger.BasicParticleSystem.initWith(200);
    
    Ranger.RandomValueParticleActivator pa = _configureForSpiralActivation(Ranger.Color4IRed, Ranger.Color4IPurple);
    pa.angleDirection = 0.0;
    
    spiralPS.particleActivation = pa;
    
    _populateParticleSystemWithCircles(spiralPS);
    spiralPS.active = true;
    spiralPS.emissionRate = 3;
    
    _spiralPS = spiralPS;
  }

  Ranger.ParticleActivation _configureForSpiralActivation(Ranger.Color4<int> fromColor, Ranger.Color4<int> toColor) {
    Ranger.RandomValueParticleActivator pa = new Ranger.RandomValueParticleActivator();
    // They all live for the same amount of time.
    pa.lifespan.min = 0.1;
    pa.lifespan.max = 2.0;
    pa.lifespan.variance = 0.5;
    
    pa.activationData.velocity.setSpeedRange(1.0, 5.0);
    pa.activationData.velocity.limitMagnitude = false;
    pa.speed.min = pa.activationData.velocity.minMagnitude;
    pa.speed.max = pa.activationData.velocity.maxMagnitude;
    pa.speed.variance = 1.0;

    pa.acceleration.min = 0.0;
    pa.acceleration.max = 0.0;
    pa.acceleration.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
   
    pa.startScale.min = 1.0;
    pa.startScale.max = 1.5;
    pa.startScale.variance = 0.5;
    
    pa.endScale.min = 6.0;
    pa.endScale.max = 15.5;
    pa.endScale.variance = 6.5;
    
    pa.startColor.setWith(fromColor);
    pa.endColor.setWith(toColor);
    return pa;
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
