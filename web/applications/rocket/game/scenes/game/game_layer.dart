part of ranger_rocket;

class GameLayer extends Ranger.BackgroundLayer {
  static int _nextTag = 100000;

  static const int TRIANGLE_SHIP = 0;
  static const int DUALCELL_SHIP = 1;
  int _activeShip = TRIANGLE_SHIP;
  TriangleShip _ship;
  DualCellShip _dualCellShip;

  TrianglePolygonNode _trianglePolyNode;
  SquarePolygonNode _squarePolyNode;
  
  Ranger.ParticleSystem _contactExplode;

  PointColor _selectIndicatorNode;

  PointColor _pointColorNode;
  Vector2 _circleOriginalPos = new Vector2.zero();
  
  Vector2 _layerOriginalPos = new Vector2.zero();
  
  Vector2 _localOrigin = new Vector2.zero();
  
  int _loadingCount = 0;
  bool _loaded = false;

  ZoomGroup _zoomControl;
  
  GameLayer();
 
  factory GameLayer.withColor(Ranger.Color4<int> backgroundColor, [bool centered = true, int width, int height]) {
    GameLayer layer = new GameLayer();
    layer.tag = 2010;
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = false;
    layer.color = backgroundColor;
    //layer.showOriginAxis = true;
    layer._layerOriginalPos.setFrom(layer.position);
    return layer;
  }

  @override
  bool init([int width, int height]) {
    if (super.init(width, height)) {
      
      Ranger.Application app = Ranger.Application.instance;
      UTE.Tween.registerAccessor(Ranger.SpriteImage, app.animations);
      UTE.Tween.registerAccessor(PointColor, app.animations);
      UTE.Tween.registerAccessor(GameLayer, app.animations);
      UTE.Tween.registerAccessor(TrianglePolygonNode, app.animations);
      
      _loaded = false;

      _configure();
    }
    
    return true;
  }

  void _configure() {
    _zoomControl = new ZoomGroup.basic();
    addChild(_zoomControl, 10);
    _zoomControl.iconVisible = true;
    _zoomControl.zoomIconVisible = true;
    _zoomControl.iconScale = 50.0;
    //_zoomControl.setPosition(-100.0, -100.0);
    _zoomControl.scaleCenter.setValues(50.0, 50.0);
    
    //---------------------------------------------------------------
    // Create nodes.
    //---------------------------------------------------------------
    _ship = new TriangleShip.basic();
    _zoomControl.addChild(_ship, 10);
    _ship.configure(_zoomControl);
    _ship.directionByDegrees = 270.0;
    _ship.uniformScale = 15.0;
    
    _dualCellShip = new DualCellShip.basic();
    _zoomControl.addChild(_dualCellShip, 10);
    _dualCellShip.configure(_zoomControl);
    //_dualCellShip.directionByDegrees = 45.0;
    _dualCellShip.uniformScale = 50.0;
    _dualCellShip.setPosition(0.0, 200.0);
    
    _configureContactExplode();
    
    _trianglePolyNode = new TrianglePolygonNode();
    _zoomControl.addChild(_trianglePolyNode, 11, 703);
    _trianglePolyNode.outlined = true;
    _trianglePolyNode.enableAABoxVisual = false;
    Ranger.Color4<int> Color4IGoldYellow = new Ranger.Color4<int>.withRGBA(255, 200, 0, 128);
    _trianglePolyNode.fillColor = Color4IGoldYellow.toString();
    _trianglePolyNode.drawColor = Ranger.Color4IGreen.toString();
    _trianglePolyNode.uniformScale = 100.0;
    _trianglePolyNode.setPosition(0.0, -200.0);

    _squarePolyNode = new SquarePolygonNode();
    _zoomControl.addChild(_squarePolyNode, 11, 703);
    _squarePolyNode.setPosition(-300.0, 0.0);
    _squarePolyNode.outlined = true;
    _squarePolyNode.enableAABoxVisual = false;
    _squarePolyNode.fillColor = Ranger.Color4ISkin.toString();
    _squarePolyNode.drawColor = Ranger.Color4IBlack.toString();
    _squarePolyNode.uniformScale = 100.0;

    _pointColorNode = new PointColor.initWith(Ranger.Color4ILightBlue, Ranger.Color4IWhite);
    _zoomControl.addChild(_pointColorNode, 11, 704);
    _pointColorNode.setPosition(300.0, 0.0);
    _circleOriginalPos.setFrom(_pointColorNode.position);
    _pointColorNode.visible = true;
    _pointColorNode.uniformScale = 100.0;

    _selectIndicatorNode = new PointColor.initWith(null, Ranger.Color4IWhite);
    _zoomControl.addChild(_selectIndicatorNode, 11, 714);
    _selectIndicatorNode.setPosition(0.0, 0.0);
    _selectIndicatorNode.uniformScale = 0.0;
  }
  
  @override
  void update(double dt) {
    // Check for collisions between bullets and shapes.
    if (_activeShip == TRIANGLE_SHIP) {
      List<Ranger.Particle> bullets = _ship.gunPS.particles;
      Ranger.UniversalParticle p = _processBulletToShapesCollide(bullets);
      if (p != null)
        _ship.gunPS.deActivateParticle(p);
    }
    else if (_activeShip == DUALCELL_SHIP) {
      List<Ranger.Particle> bullets = _dualCellShip.gunPS.particles;
      Ranger.UniversalParticle p = _processBulletToShapesCollide(bullets);
      if (p != null)
        _dualCellShip.gunPS.deActivateParticle(p);
    }
    
    // Check for collision between bullets and ships
    if (_activeShip == TRIANGLE_SHIP) {
      // Did a triangle ship's bullet hit the bigger ship.
      List<Ranger.Particle> bullets = _ship.gunPS.particles;
      Ranger.UniversalParticle p = _processBulletToDualShip(bullets);
      if (p != null) {
        _ship.gunPS.deActivateParticle(p);
        // Apply force to DualCellShip in the direction of the particle.
        double angle = _ship.gunPS.particleActivation.angleDirection;
        _dualCellShip.pulseForceFrom(0.2, angle, 1.0);
        
        // Detonate a smaller particle system.
        _contactExplode.setPosition(p.node.position.x, p.node.position.y);
        _contactExplode.explodeByStyle(Ranger.ParticleActivation.OMNI_DIRECTIONAL);
      }
    }
    else if (_activeShip == DUALCELL_SHIP) {
      // Did a DualCell ship's bullet hit the smaller ship.
      List<Ranger.Particle> bullets = _dualCellShip.gunPS.particles;
      Ranger.UniversalParticle p = _processBulletToTriangleShip(bullets);
      if (p != null) {
        _dualCellShip.gunPS.deActivateParticle(p);
        double angle = _dualCellShip.gunPS.particleActivation.angleDirection;
        // Apply force to Triangle ship in the direction of the particle.
        _ship.pulseForceFrom(0.1, angle, 2.0);
        
        // Dentonate a smaller particle system.
        _contactExplode.setPosition(p.node.position.x, p.node.position.y);
        _contactExplode.explodeByStyle(Ranger.ParticleActivation.OMNI_DIRECTIONAL);
      }
    }
  }

  Ranger.UniversalParticle _processBulletToTriangleShip(List<Ranger.Particle> bullets) {
    bool collide = false;
    
    for(Ranger.UniversalParticle p in bullets) {
      if (p.active) {
        Ranger.Vector2P pw = p.node.convertToWorldSpace(_localOrigin);
        Ranger.Vector2P nodeP = _ship.convertWorldToNodeSpace(pw.v);
        pw.moveToPool();

        collide = _ship.pointInside(nodeP.v);
        if (collide) {
          nodeP.moveToPool();
          return p;
        }
        
        nodeP.moveToPool();
      }
    }
    
    return null;
  }
  
  Ranger.UniversalParticle _processBulletToDualShip(List<Ranger.Particle> bullets) {
    bool collide = false;
    
    for(Ranger.UniversalParticle p in bullets) {
      if (p.active) {
        Ranger.Vector2P pw = p.node.convertToWorldSpace(_localOrigin);

        collide = _dualCellShip.pointInside(pw.v);
        if (collide) {
          pw.moveToPool();
          return p;
        }
        
        pw.moveToPool();
      }
    }
    
    return null;
  }
  
  Ranger.UniversalParticle _processBulletToShapesCollide(List<Ranger.Particle> bullets) {
    bool collide = false;
    
    for(Ranger.UniversalParticle p in bullets) {
      if (p.active) {
        // p.node is a CircleParticleNode and is consider a point.
        // _pointColorNode is considered as having a radius.
        collide = _pointColorNode.collide(p.node);
        if (collide) {
          _handleBulletToCircleCollide();
          return p;
        }

        // To check the square we need to map the bullet's position from
        // local-space to the local-space of the square. This better than
        // mapping all the vertices of the square into the space of the
        // particle (aka 4 mappings verse 1).
        // The particle' local-space origin is of course 0,0
        Ranger.Vector2P pw = p.node.convertToWorldSpace(_localOrigin);
        Ranger.Vector2P nodeP = _squarePolyNode.convertWorldToNodeSpace(pw.v);

        collide = _squarePolyNode.pointInside(nodeP.v);
        if (collide) {
          _handleBulletToSquareCollide();
          pw.moveToPool();
          nodeP.moveToPool();
          return p;
        }
        
        pw.moveToPool();
        nodeP.moveToPool();

        pw = p.node.convertToWorldSpace(_localOrigin);
        nodeP = _trianglePolyNode.convertWorldToNodeSpace(pw.v);

        collide = _trianglePolyNode.pointInside(nodeP.v);
        if (collide) {
          _handleBulletToTriangleCollide();
          pw.moveToPool();
          nodeP.moveToPool();
          return p;
        }
        
        pw.moveToPool();
        nodeP.moveToPool();
      
      }
    }

    return null;
  }
  
  void _handleBulletToCircleCollide() {
    Ranger.Application app = Ranger.Application.instance;
    UTE.Tween shake = app.animations.shake(
        _pointColorNode,
        0.25,
        5.0,
        (int type, UTE.BaseTween source) {
          switch(type) {
            case UTE.TweenCallback.END:
              Ranger.Node n = source.userData as Ranger.Node;
              n.position.setFrom(_circleOriginalPos);
              break;
          }
        }
    );
  }
  
  void _handleBulletToSquareCollide() {
    Ranger.Application app = Ranger.Application.instance;
    UTE.Tween shake = app.animations.shake(
        this,
        0.25,
        2.0,
        (int type, UTE.BaseTween source) {
          switch(type) {
            case UTE.TweenCallback.END:
              Ranger.Node n = source.userData as Ranger.Node;
              n.position.setFrom(_layerOriginalPos);
              break;
          }
        }
      );
  }
  
  void _handleBulletToTriangleCollide() {
    Ranger.Application app = Ranger.Application.instance;

    app.animations.stop(_trianglePolyNode, Ranger.TweenAnimation.SCALE_XY);
    // Remember that animations keep running independent of the Node.
    // So if you don't stop them they will continue to effect the node
    // plus they will accumulate. In this case the effect is pretty cool
    // so I purposefully let the rotations accumulate.
    //app.animations.stop(_trianglePolyNode, Ranger.TweenAnimation.ROTATE);
    
    UTE.Timeline seq = new UTE.Timeline.sequence();

    UTE.Tween scaleUp = app.animations.scaleTo(
        _trianglePolyNode,
        0.5,
        200.0, 200.0,
        UTE.Elastic.OUT,
        Ranger.TweenAnimation.SCALE_XY,
        null, Ranger.TweenAnimation.NONE,
        false);
    seq.push(scaleUp);

    UTE.Tween scaleDown = app.animations.scaleTo(
        _trianglePolyNode,
        1.0,
        100.0, 100.0,
        UTE.Linear.INOUT,
        Ranger.TweenAnimation.SCALE_XY,
        null, Ranger.TweenAnimation.NONE,
        false);
    seq.push(scaleDown);

    UTE.Tween rotate = app.animations.rotateBy(
        _trianglePolyNode,
        0.25,
        5.0,
        UTE.Cubic.INOUT,
        null,
        false);
    seq.push(rotate);

    seq.start();
  }
  
  @override
  void onEnter() {
    enableKeyboard = true;
    enableMouse = true;
    super.onEnter();

    _setViewportAABBox();
    
    // We want regular updates such that we can perform collision checks.
    // Of course this means we need to override the update(...) method.
    scheduleUpdate();
  }
  
  @override
  void onExit() {
    super.onExit();
    
    Ranger.Application.instance.scheduler.unScheduleTimingTarget(_contactExplode);
    
    unScheduleUpdate();
  }

  @override
  bool onMouseDown(MouseEvent event) {
    if (event.altKey) {
      Ranger.Application app = Ranger.Application.instance;
      // Use "this" when mapping the position
      // Use "_zoomControl" when mapping the scaleCenter.
      Ranger.Vector2P nodeP = app.drawContext.mapViewToNode(_zoomControl, event.offset.x, event.offset.y);
      
      _zoomControl.scaleCenter.setFrom(nodeP.v);
      nodeP.moveToPool();
      return true;
    }
    
    return false;
  }

  // Should be called when zoom changes.
  void _setViewportAABBox() {
    Ranger.SceneManager sm = Ranger.Application.instance.sceneManager;

    double zValue = 1.0;
    
    // Note: should hold ref to scene instead of searching for it.
    Ranger.GroupingBehavior sceneGB = sm.runningScene as Ranger.GroupingBehavior;
    Ranger.BaseNode layer = sceneGB.getChildByTag(2010);
    if (layer != null) {
      layer.uniformScale = zValue;
    }

    Ranger.Application app = Ranger.Application.instance; 

    // We want the viewport to remain fixed relative to view-space.
    // Hence, if the Layer zooms in we want the viewport to do the
    // opposite.
    // Instead of mapping the viewPort Node into world-space we
    // map app.viewPortAABB to world-space.
    Ranger.DrawContext dc = app.drawContext;
    Ranger.MutableRectangle<double> worldRect = dc.mapViewRectToWorld(app.viewPortAABB);
    //print("worldRect: $worldRect");
    
    // and then for visuals we map the worldRect to the viewPort Node
    // for rendering. The viewPort Node is a centered square.
    Ranger.MutableRectangle<double> nodeRect = convertWorldRectToNode(worldRect);
    //print("nodeRect: $nodeRect");
    //viewPort.scaleTo(nodeRect.width, nodeRect.height);

    worldRect.moveToPool();
    nodeRect.moveToPool();

    app.viewPortWorldAABB.setWith(worldRect);
    
    //print("_zoomChanged: ${app.viewPortWorldAABB}");

    // Mark all Nodes dirty so that their boxes are updated as well.
    rippleDirty();
  }

  @override
  bool onKeyDown(KeyboardEvent event) {
    //print("key onKeyDown ${event.keyCode}");

    switch (event.keyCode) {
      case 49: //1
        _zoomControl.currentScale = 1.0;
        return true;
      case 50: //2
        _zoomControl.currentScale = 2.0;
        return true;
      case 51: //3
        _zoomControl.zoomBy(0.1);
        return true;
      case 52: //4
        _zoomControl.zoomBy(-0.1);
        return true;
      case 84: //t
        return true;
      case 90: //z
        // CCW
        if (_activeShip == TRIANGLE_SHIP)
          _ship.rotateCCWOn();
        else if (_activeShip == DUALCELL_SHIP)
          _dualCellShip.rotateCCWOn();
        return true;
      case 65: //a
        // CW
        if (_activeShip == TRIANGLE_SHIP)
          _ship.rotateCWOn();
        else if (_activeShip == DUALCELL_SHIP)
          _dualCellShip.rotateCWOn();
        return true;
      case 191: // "/" thrust
        if (_activeShip == TRIANGLE_SHIP)
          _ship.thrust(true);
        else if (_activeShip == DUALCELL_SHIP)
          _dualCellShip.thrust(true);
        return true;
      case 222: // "'" fire
        if (_activeShip == TRIANGLE_SHIP)
          _ship.fire(true);
        else if (_activeShip == DUALCELL_SHIP)
          _dualCellShip.fire(true);
        return true;
    }
    
    return false;
  }

  @override
  bool onKeyUp(KeyboardEvent event) {
    //print("key onKeyUp ${event.keyEvent.keyCode}");
    switch (event.keyCode) {
      case 90: //z
        // CCW
        if (_activeShip == TRIANGLE_SHIP)
          _ship.rotateCCWOff();
        else if (_activeShip == DUALCELL_SHIP)
          _dualCellShip.rotateCCWOff();
        return true;
      case 65: //a
        // CW
        if (_activeShip == TRIANGLE_SHIP)
          _ship.rotateCWOff();
        else if (_activeShip == DUALCELL_SHIP)
          _dualCellShip.rotateCWOff();
        return true;
      case 191: // "/" thrust
        if (_activeShip == TRIANGLE_SHIP)
          _ship.thrust(false);
        else if (_activeShip == DUALCELL_SHIP)
          _dualCellShip.thrust(false);
        return true;
      case 222: // "'" fire
        if (_activeShip == TRIANGLE_SHIP)
          _ship.fire(false);
        else if (_activeShip == DUALCELL_SHIP)
          _dualCellShip.fire(false);
        return true;
    }
    
    return false;
  }

  set activeShip(int shipId) {
    _activeShip = shipId;
    
    // Animate a ring around ship.
    Ranger.Application app = Ranger.Application.instance;
    _selectIndicatorNode.visible = true;
    // The tween must have a value other than zero to begin interpolating.
    _selectIndicatorNode.uniformScale = 1.0;
    
    if (shipId == TRIANGLE_SHIP) {
      _selectIndicatorNode.position = _ship.position;
    }
    else if (shipId == DUALCELL_SHIP) {
      _selectIndicatorNode.position = _dualCellShip.position;
    }
    
    UTE.Timeline seq = new UTE.Timeline.sequence();

    UTE.Tween scaleUp = app.animations.scaleTo(
        _selectIndicatorNode,
        1.0,
        100.0, 100.0,
        UTE.Bounce.OUT, Ranger.TweenAnimation.SCALE_XY,
        null, Ranger.TweenAnimation.MULTIPLY,
        false);
    seq.push(scaleUp);

    UTE.Tween hide = app.animations.hide(
        _selectIndicatorNode,
        null, false);
    seq.push(hide);

    seq.start();
  }
  
  // -----------------------------------------------------------------
  // Construct Exhaust and Particles
  // -----------------------------------------------------------------
  void _configureContactExplode() {
    _contactExplode = new Ranger.BasicParticleSystem.initWith(10);
    _contactExplode.setPosition(position.x, position.y);
    
    Ranger.RandomValueParticleActivator pa = _configureForExhaustActivation(Ranger.Color4IRed, Ranger.Color4IYellow);
    
    _contactExplode.particleActivation = pa;

    // Construct Exhaust Particles
    _populateParticleSystemWithCircles(_contactExplode);
    _contactExplode.active = true;
    
    Ranger.Application.instance.scheduler.scheduleTimingTarget(_contactExplode);
  }
  
  Ranger.ParticleActivation _configureForExhaustActivation(Ranger.Color4<int> fromColor, Ranger.Color4<int> toColor) {
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

  void _populateParticleSystemWithCircles(Ranger.ParticleSystem ps, [Ranger.Color4<int> fromColor, Ranger.Color4<int> toColor]) {
    // To populate a particle system we need prototypes to clone from.
    // Once the particle system has been built we can dispense with the
    // prototypes.

    if (fromColor == null)
      fromColor = Ranger.Color4IBlack;
    if (toColor == null)
      toColor = Ranger.Color4IWhite;

    // First we create a "prototype" visual which will be assigned to a
    // prototype particle.
    CircleParticleNode protoVisual = new CircleParticleNode.initWith(fromColor);
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
    prototype.initWithColor(fromColor, toColor);
    prototype.initWithScale(1.0, 15.0);
    
    // Now we populate the particle system with "clones" of the prototype.
    // The particles will be emitted onto the main GameLayer.
    // If we had supplied "this" then the particles are emitted as children
    // of the ship and that would visually look incorrect, plus they
    // would inherit transform properties of the ship that we don't want.
    ps.addByPrototype(_zoomControl, prototype);
    
    // The prototype is no longer relevant as it has been cloned. So
    // we move it back to the pool.
    protoVisual.moveToPool();
    prototype.moveToPool();
  }
}
