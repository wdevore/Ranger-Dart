part of template6;

/**
 * A simple layer that demonstrates displaying a HTML panel.
 */
class GameLayer extends Ranger.BackgroundLayer {
  static int _nextTag = 100000;
  
  int _listTag;
  Ranger.SpriteImage _listSprite;
  
  Ranger.OverlayLayer _loadingOverlay;
  Ranger.SpriteImage _overlaySpinner;
  
  int _loadingCount = 0;
  bool _loaded = false;
  
  TestsDialog _testsPanel;

  Ranger.ParticleSystem _starPS;
  int particleEmissionStyle = Ranger.ParticleActivation.OMNI_DIRECTIONAL;
  bool _paused = false;
  
  GameLayer();
 
  factory GameLayer.withColor(Ranger.Color4<int> backgroundColor, [bool centered = true, int width, int height]) {
    GameLayer layer = new GameLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = false;
    layer.color = backgroundColor;
    layer.showOriginAxis = false;
    return layer;
  }

  @override
  bool init([int width, int height]) {
    if (super.init(width, height)) {
      _testsPanel = new TestsDialog.withHideCallback(_panelAction);
    }
    
    return true;
  }
  
  @override
  void onEnter() {
    Ranger.Application app = Ranger.Application.instance;

    // We need to register the a few classes so that the
    // Universal Tween Engine (UTE) recognizes them.
    UTE.Tween.registerAccessor(Ranger.SpriteImage, app.animations);

    _loaded = false;

    _configure();
    
    super.onEnter();
    
    // This layer needs updates in order to drive the particle system.
    // Scheduling causes this layer/node to receive updates.
    scheduleUpdate();
  }

  @override
  void onExit() {
    super.onExit();
    
    Ranger.Application app = Ranger.Application.instance;
    app.animations.stop(_listSprite, Ranger.TweenAnimation.ROTATE);
    
    unScheduleUpdate();
  }

  @override
  bool onMouseDown(MouseEvent event) {
    if (!_loaded || _testsPanel.isShowing)
      return false;
    
    Ranger.Application app = Ranger.Application.instance;
    Ranger.Vector2P nodeP = app.drawContext.mapViewToNode(_listSprite, event.offset.x, event.offset.y);
    //        v-----------------------------------^
    // The mapping methods always return pooled objects, so be sure to
    // return them to the pool otherwise your app will progressively
    // leak.
    nodeP.moveToPool();

    if (_listSprite.containsPoint(nodeP.v)) {
      _listSprite.rotationByDegrees = 0.0;
      app.animations.stop(_listSprite, Ranger.TweenAnimation.ROTATE);

      // Create an animation that when completed will trigger a transition.
      UTE.Timeline seq = new UTE.Timeline.sequence();
      
      UTE.Tween tw1 = app.animations.rotateTo(
          _listSprite,
          0.15,
          -5.0, // CW
          UTE.Cubic.OUT,
          null, false);

      seq.push(tw1);

      UTE.Tween tw2 = app.animations.rotateTo(
          _listSprite,
          0.15,
          10.0,
          UTE.Cubic.OUT,
          null, false);

      seq.push(tw2);

      UTE.Tween tw3 = app.animations.rotateTo(
          _listSprite,
          0.15,
          0.0,
          UTE.Cubic.OUT,
          null, false);

      seq.push(tw3);
      
      seq.start();

      _testsPanel.show();

      return true;
    }

    return false;
  }

  @override
  void update(double dt) {
    if (!_paused) {
      _starPS.activateByStyle(particleEmissionStyle);
      _starPS.update(dt);
    }
  }
  
  _panelAction(String title) {
    switch(title) {
      case "Pause/Resume":
        _paused = !_paused;
        break;
      case "Sparkler":
        particleEmissionStyle = Ranger.ParticleActivation.OMNI_DIRECTIONAL;
        break;
      case "Hose":
        particleEmissionStyle = Ranger.ParticleActivation.DRIFT_DIRECTIONAL;
        break;
      case "Thrust":
        particleEmissionStyle = Ranger.ParticleActivation.VARIANCE_DIRECTIONAL;
        break;
    }
  }
  
  void _loadingUpdate(int tag) {
    if (tag == _listTag) {
      // The sprite associated with the tag has now loaded and been added
      // to the scene graph when the Future completed in the Closure; see
      // _loadImage() for the Closure.
      _listSprite = getChildByTag(_listTag);
      _listSprite.uniformScale = 1.5;
    }
    
    // Have all the assets loaded.
    if (_loadingCount == 0) {
      enableMouse = true;
      enableInputs();
      
      Ranger.Application app = Ranger.Application.instance;
      app.animations.flush(_overlaySpinner);
      
      // All sprites have loaded. Remove overlay.
      // I specify "true" because this Layer Node isn't needed ever again.
      //              ^--------------v
      removeChild(_loadingOverlay, true);
      _loaded = true;
    }
  }

  void _configure() {
    //---------------------------------------------------------------
    // Text node
    //---------------------------------------------------------------
    Ranger.TextNode desc = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    desc.text = "Ranger GameLayer Template 6";
    desc.shadows = true;
    desc.setPosition(-220.0, 300.0);
    desc.uniformScale = 3.0;
    addChild(desc, 10, 445);

    Ranger.TextNode help = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    help.text = "Tap icon to reveal panel.";
    help.shadows = true;
    help.setPosition(-170.0, 250.0);
    help.uniformScale = 3.0;
    addChild(help, 10, 445);

    //---------------------------------------------------------------
    // Loading-overlay
    //---------------------------------------------------------------
    _configOverlay();
    
    //---------------------------------------------------------------
    // Sprites
    //---------------------------------------------------------------
    _listTag = _loadImage("resources/list.svg", 32, 32, 200.0, 260.0, true);
    
    //---------------------------------------------------------------
    // Particles
    //---------------------------------------------------------------
    _configureMiddlePS();
    _starPS.setPosition(0.0, 0.0);

  }
  
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

  void _configOverlay() {
    Ranger.Color4<int> darkBlue = new Ranger.Color4<int>.withRGBA(109~/3, 157~/3, 235~/3, 128);
    _loadingOverlay = new Ranger.OverlayLayer.withColor(darkBlue);
    _loadingOverlay.transparentBackground = false;
    addChild(_loadingOverlay, 20, 555);
    
    Ranger.TextNode loading = new Ranger.TextNode.initWith(Ranger.Color4IOrange);
    loading.text = "Loading...";
    loading.shadows = true;
    loading.setPosition(-150.0, -300.0);
    loading.uniformScale = 8.0;
    _loadingOverlay.addChild(loading, 10, 556);

    Resources resources = GameManager.instance.resources;
    
    Ranger.Application app = Ranger.Application.instance;
    _overlaySpinner = resources.getSpinnerRing(1.5, -360.0, 7001);
    // Track this infinite animation.
    app.animations.track(_overlaySpinner, Ranger.TweenAnimation.ROTATE);

    _loadingOverlay.addChild(_overlaySpinner);
  }
  
  int _loadImage(String resource, int width, int height, double px, double py, [bool simulateLoadingDelay = false]) {
    Ranger.Application app = Ranger.Application.instance;
    Resources resources = GameManager.instance.resources;

    _loadingCount++;
    
    // Grab current tag prior to bumping.
    int tg = _nextTag;
    
    // I use a Closure to capture the placebo sprite such that it can
    // be used while the actual image is loading.
    (int ntag) {  // <--------- Closure
      // While the actual image is loading, display an animated placebo.
      Ranger.SpriteImage placebo = resources.getSpinner(7000);
      // Track this infinite animation.
      app.animations.track(placebo, Ranger.TweenAnimation.ROTATE);

      placebo.setPosition(px, py);
      addChild(placebo, 10);
      
      // Start loading image
      // This Template example enables Simulated Loading Delay. You
      // wouldn't do this in production. Just leave the parameter missing
      // as it is optional and defaults to "false/disabled".
      //                                         ^-------v
      resources.loadImage(resource, width, height, simulateLoadingDelay).then((ImageElement ime) {
        // Image has finally loaded.
        // Terminate placebo's animation.
        app.animations.flush(placebo);

        // Remove placebo and capture index for insertion of actual image.
        int index = removeChild(placebo);
        
        // Now that the image is loaded we can create a sprite from it.
        Ranger.SpriteImage spri = new Ranger.SpriteImage.withElement(ime);
        // Add the image at the place-order of the placebo.
        addChildAt(spri, index, 10, ntag);
        spri.setPosition(px, py);

        _loadingCount--;
        
        _loadingUpdate(ntag);
      });
    }(tg);// <---- Immediately execute the Closure.
    
    _nextTag++;
    
    return tg;
  }
  
}
