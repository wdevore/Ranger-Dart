part of ranger_rocket;

/*
 * This ship has dual thrusters and dual guns.
 * It doesn't have thrust moments. Thrust is still applied to the centroid.
 */
class DualCellShip extends Ranger.Node with Ranger.GroupingBehavior {
  static const double MAX_MAGNITUDE = 10.0;
  static const double MAX_THRUST_MAGNITUDE = 0.05;
  
  Ranger.Velocity _thrust = new Ranger.Velocity();
  Ranger.Velocity _momentum = new Ranger.Velocity();
  
  bool _thrustOn = false;
  bool _rotateCWOn = false;
  bool _rotateCCWOn = false;
  double angle = 0.0;
  double thrustAngle = 0.0;
  double angularSpeed = 1.0;

  // A short pulse of force being apply to this ship.
  bool _pulseOn = false;
  double _pulseDuration = 0.0;
  double _pulseDurationCount = 0.0;
  double _pulseAngle = 0.0;
  double _pulseMag = 1.0;
  Ranger.Velocity _pulseForce = new Ranger.Velocity();
  
  Ranger.GroupNode _centerMass = new Ranger.GroupNode.basic();

  // Main hull
  PointColor _mainHull;
  SquarePolygonNode _leftCell;
  SquarePolygonNode _rightCell;

  // ------------------------------------------------------------
  // Exhaust particle systems.
  // ------------------------------------------------------------
  Ranger.ParticleSystem _exhaustLeftPS;
  // The relative location for the exhaust
  Ranger.EmptyNode _exhaustLeftPort = new Ranger.EmptyNode();
  
  Ranger.ParticleSystem _exhaustRightPS;
  Ranger.EmptyNode _exhaustRightPort = new Ranger.EmptyNode();
  
  // ------------------------------------------------------------
  // Gun particle systems.
  // ------------------------------------------------------------
  Ranger.ParticleSystem gunPS;
  // The relative location for the gun
  Ranger.EmptyNode _gunPort = new Ranger.EmptyNode();
  bool _firing = false;
  
  Ranger.Velocity _bulletVelocity = new Ranger.Velocity();
  
  // The layer where particles are emitted.
  Ranger.GroupNode _mainLayer;

  DualCellShip();

  DualCellShip._();
  
  factory DualCellShip.basic() {
    DualCellShip node = new DualCellShip._();
    
    if (node.init()) {
      node.tag = 2099;
      return node;
    }
    
    return null;
  }

  @override
  bool init() {
    if (super.init()) {
      initGroupingBehavior(this);
    }

    return true;
  }

  void configure(Ranger.GroupNode mainLayer) {
    // The GameLayer is required because we are emitting particles onto
    // that layer. The particles need to be emitted onto an independent
    // layer otherwise then would be in sync with the ship. This concept
    // is identical to the physical world.
    _mainLayer = mainLayer;
    
    _build();
    
    _thrust.maxMagnitude = MAX_THRUST_MAGNITUDE;
    _momentum.maxMagnitude = MAX_MAGNITUDE;
    
    _configureExhaust();
    
    _configureGun();
    
    // Default to +X axis
    directionByDegrees = 0.0;
  }
  
  set directionByDegrees(double angle) {
    //----------------------------------------------------------------
    // Default the momentum and thrust to the same angle.
    //----------------------------------------------------------------
    this.angle = thrustAngle = rotationByDegrees = angle;

    _momentum.directionByDegrees = this.angle;
    
    _thrust.directionByDegrees = thrustAngle;
    
    if (_exhaustLeftPS != null) {
      // Why is the exhaust particles' direction opposite that of the thrust?
      // Because the thrust is a vector in the direction of the ship (aka additive).
      _exhaustLeftPS.particleActivation.angleDirection = _thrust.asAngleInDegrees + 180.0;
    }
    
    if (_exhaustRightPS != null) {
      // Why is the exhaust particles' direction opposite that of the thrust?
      // Because the thrust is a vector in the direction of the ship (aka additive).
      _exhaustRightPS.particleActivation.angleDirection = _thrust.asAngleInDegrees + 180.0;
    }
    
    if (gunPS != null)
      gunPS.particleActivation.angleDirection = _thrust.asAngleInDegrees;
  }

  // -----------------------------------------------------------------
  // Construct Gun and Particles
  // -----------------------------------------------------------------
  void _configureGun() {
    gunPS = new Ranger.BasicParticleSystem.initWith(5);

    gunPS.setPosition(position.x, position.y);
    
    Ranger.RandomValueParticleActivator pa = _configureForGunActivation();
    pa.angleDirection = _thrust.asAngleInDegrees;
    pa.angleVariance = 0.0;
    
    gunPS.particleActivation = pa;

    // Construct Gun Particles
    _populateParticleSystemWithCircles(gunPS, Ranger.Color4IBlue, Ranger.Color4IGrey);
    gunPS.active = true;
    
    // #### Debug visual BEGIN
    //Ranger.ParticleSystemVisual visual = _gunPS.emitterVisual;
    //visual.size = 10.0;
    //_gameLayer.addChild(visual, 200, 5001);
    // #### END
    
    _gunPort.setPosition(1.0, 0.0);
    _gunPort.visible = false;
    addChild(_gunPort, 202, 5003);
  }
  
  Ranger.ParticleActivation _configureForGunActivation() {
    Ranger.RandomValueParticleActivator pa = new Ranger.RandomValueParticleActivator();
    // They all live for the same amount of time.
    pa.lifespan.min = 0.0;
    pa.lifespan.max = 2.0;
    pa.lifespan.clampVarianceTo(Ranger.Variance.CLAMP_TO_MAX);
    
    pa.activationData.velocity.setSpeedRange(0.0, 10.0);
    pa.activationData.velocity.limitMagnitude = false;
    pa.speed.min = pa.activationData.velocity.minMagnitude;
    pa.speed.max = pa.activationData.velocity.maxMagnitude;
    pa.speed.clampVarianceTo(Ranger.Variance.CLAMP_TO_MAX);

    pa.acceleration.min = 0.0;
    pa.acceleration.max = 0.0;
    pa.acceleration.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
   
    pa.startScale.min = 3.0;
    pa.startScale.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
    pa.endScale.min = 3.0;
    pa.endScale.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
    
    pa.startColor.setWith(Ranger.Color4IYellow);
    pa.endColor.setWith(Ranger.Color4IGoldYellow);
    return pa;
  }

  // -----------------------------------------------------------------
  // Construct Exhaust and Particles
  // -----------------------------------------------------------------
  void _configureExhaust() {
    
    _exhaustLeftPS = new Ranger.BasicParticleSystem.initWith(40);
    _exhaustLeftPS.setPosition(position.x, position.y);
    
    Ranger.RandomValueParticleActivator pa = _configureForExhaustActivation(Ranger.color4IFromHex("#86647a"), Ranger.Color4IGoldYellow);
    pa.angleDirection = _thrust.asAngleInDegrees;
    pa.angleVariance = 50.0;
    
    _exhaustLeftPS.particleActivation = pa;

    // Construct Exhaust Particles
    _populateParticleSystemWithCircles(_exhaustLeftPS);
    _exhaustLeftPS.active = true;
    
    // #### Debug visual BEGIN
    //Ranger.ParticleSystemVisual visual = _exhaustPS.emitterVisual;
    //visual.size = 10.0;
    //_gameLayer.addChild(visual, 200, 5001);
    // #### END
    
    // The port is where the particles are emitted from.
    _exhaustLeftPort.setPosition(-1.1, 0.6);
    _exhaustLeftPort.visible = false;
    //_exhaustLeftPort.iconVisible = true;
    addChild(_exhaustLeftPort, 201, 5002);

    // ----------------------------------------------------------
    // RIGHT
    // ----------------------------------------------------------
    _exhaustRightPS = new Ranger.BasicParticleSystem.initWith(40);
    _exhaustRightPS.setPosition(position.x, position.y);
    
    pa = _configureForExhaustActivation(Ranger.color4IFromHex("#86647a"), Ranger.Color4IGoldYellow);
    pa.angleDirection = _thrust.asAngleInDegrees;
    pa.angleVariance = 50.0;
    
    _exhaustRightPS.particleActivation = pa;

    // Construct Exhaust Particles
    _populateParticleSystemWithCircles(_exhaustRightPS);
    _exhaustRightPS.active = true;
    
    // #### Debug visual BEGIN
    //Ranger.ParticleSystemVisual visual = _exhaustPS.emitterVisual;
    //visual.size = 10.0;
    //_gameLayer.addChild(visual, 200, 5001);
    // #### END
    
    // The port is where the particles are emitted from.
    _exhaustRightPort.setPosition(-1.1, -0.6);
    _exhaustRightPort.visible = false;
    //_exhaustRightPort.iconVisible = true;
    addChild(_exhaustRightPort, 201, 5002);
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


  void _build() {
    _centerMass = new Ranger.GroupNode.basic();
    _centerMass.setPosition(0.0, 0.0);
    //_centerMass.iconVisible = true;
    addChild(_centerMass, 11, 1234);
    
    Ranger.Color4<int> Color4IOrangeAlpha = new Ranger.Color4<int>.withRGBA(255, 127, 0, 128);
    
    _mainHull = new PointColor.initWith(Color4IOrangeAlpha, Ranger.Color4IWhite);
    _mainHull.setPosition(0.5, 0.0);
    _mainHull.visible = true;
    _centerMass.addChild(_mainHull, 11, 7100);

    _leftCell = new SquarePolygonNode();
    addChild(_leftCell, 11, 7800);
    _leftCell.setPosition(-0.65, 0.65);
    _leftCell.scaleX = 1.0;
    _leftCell.scaleY = 0.5;
    _leftCell.outlined = true;
    _leftCell.enableAABoxVisual = false;
    _leftCell.fillColor = Ranger.color4IFromHex("#86647a").toString();
    _leftCell.drawColor = Ranger.Color4IWhite.toString();

    _rightCell = new SquarePolygonNode();
    addChild(_rightCell, 11, 7801);
    _rightCell.setPosition(-0.65, -0.65);
    _rightCell.scaleX = 1.0;
    _rightCell.scaleY = 0.5;
    _rightCell.outlined = true;
    _rightCell.enableAABoxVisual = false;
    _rightCell.fillColor = Ranger.color4IFromHex("#86647a").toString();
    _rightCell.drawColor = Ranger.Color4IWhite.toString();
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
    ps.addByPrototype(_mainLayer, prototype);
    
    // The prototype is no longer relevant as it has been cloned. So
    // we move it back to the pool.
    protoVisual.moveToPool();
    prototype.moveToPool();
  }

  /**
   * [point] is in world-space.
   */
  @override
  bool pointInside(Vector2 point) {
    // Map world-space point into this ship's space.
    Ranger.Vector2P nodeP = convertWorldToNodeSpace(point);
    // Note: if you use _mainHull.convertWorldToNodeSpace(...) then
    // you need to map back to ship/centerMass-space by adding
    // nodeP.v.add(_mainHull.position);
    
    bool collide = _mainHull.collideByPoint(nodeP.v);
    nodeP.moveToPool();
    
    if (!collide) {
      nodeP = _leftCell.convertWorldToNodeSpace(point);
      collide = _leftCell.pointInside(nodeP.v);
      nodeP.moveToPool();
      if (!collide) {
        nodeP = _rightCell.convertWorldToNodeSpace(point);
        collide = _rightCell.pointInside(nodeP.v);
        nodeP.moveToPool();
      }
    }

    return collide;
  }

  @override
  void onEnter() {
    super.onEnter();

    // Because the ship needs to "watch" for state changes and has a particle
    // system, we need to schedule this node for clock ticks.
    scheduleUpdate();
  }
  
  @override
  void onExit() {
    super.onExit();
    unScheduleUpdate();
  }

  @override
  void update(double dt) {
    if (_thrustOn) {
      applyThrust();
      // Trigger another particle if one is available.
      _exhaustLeftPS.activateByStyle(Ranger.ParticleActivation.VARIANCE_DIRECTIONAL);
      _exhaustRightPS.activateByStyle(Ranger.ParticleActivation.VARIANCE_DIRECTIONAL);
    }

    // ------------------------
    // Pulse force
    // ------------------------
    if (_pulseOn) {
      _pulseDurationCount += dt;
      if (_pulseDurationCount > _pulseDuration) {
        _pulseOn = false;
        _pulseDurationCount = 0.0;
      }
      // Form a force vector and apply to ship's position
      _pulseForce.directionByDegrees = _pulseAngle;
      _pulseForce.magnitude = _pulseMag;
    }
    
    if (_pulseForce.speed > _pulseForce.minMagnitude) {
      _pulseForce.applyTo(position);
      dirty = true;   // <--- You signal that the transform is dirty.
    }
    
    if (_pulseForce.speed > 0.0) {
      _pulseForce.decreaseSpeed(0.025);
    }
    
    if (_rotateCWOn && _rotateCCWOn) {
        // Rotating in both directions results in nothing.
    }
    else if (_rotateCWOn) {
        rotate(true);
        rotationByDegrees = angle;
    }
    else if (_rotateCCWOn) {
        rotate(false);
        rotationByDegrees = angle;
    }
    
    // Update the ship's position based on the momentum. If there is drag
    // then the momentum will steadily decrease until it reaches a magnitude
    // of zero.
    // Take the ship's current momentum--which is independent of the ship's
    // current thrust direction--and apply thrust/force to it. We want to change the
    // ship's momentum not direction.
    if (_thrust.speed > 0.0)
        _momentum.add(_thrust);
    
    // Now update the ship's position based on the momentum.
    if (_momentum.speed > _momentum.minMagnitude) {
      _momentum.applyTo(position);
      dirty = true;   // <--- You signal that the transform is dirty.
    }
    
    // If there is no thrust being applied then the thrust slowly dies off.
    if (_thrust.speed > 0.0)
      decreaseSpeed();
      
    // Update momentum if there is drag.
    _momentum.decreaseSpeed(0.01);

    // The exhaust port is an empty place holder used to track a location.
    // In this case we use it to track the position at the end of the ship.
    // Convert the exhaust port's local-space to world-space relative
    // to the ship's space. Why? Because the port is a child of "this"
    // ship so it is in ship-space.
    // Then convert it into GameLayer-space because the exhaust particle
    // system is in that space.
    Vector2 gs = _convertToGameLayerSpace(_exhaustLeftPort.position);
    _exhaustLeftPS.setPosition(gs.x, gs.y);
    gs = _convertToGameLayerSpace(_exhaustRightPort.position);
    _exhaustRightPS.setPosition(gs.x, gs.y);

    gs = _convertToGameLayerSpace(_gunPort.position);
    gunPS.setPosition(gs.x, gs.y);

    if (_firing) {
      _firing = false;
      gunPS.activateByStyle(Ranger.ParticleActivation.UNI_DIRECTIONAL);
    }
    
    _exhaustLeftPS.update(dt);
    _exhaustRightPS.update(dt);
    gunPS.update(dt);
  }
  
  Vector2 _convertToGameLayerSpace(Vector2 location) {
    Ranger.Vector2P ws = convertToWorldSpace(location);
    // Now convert it into GameLayer-space.
    Ranger.Vector2P ns = _mainLayer.convertWorldToNodeSpace(ws.v);

    // Clean up.
    ns.moveToPool();
    ws.moveToPool();
    
    // It is okay to return ns.v because it only been returned to
    // the pool. Of course the callie shouldn't hold it permanently
    // either.
    return ns.v;
  }
  
  void rotate(bool direction) {
    if (direction) {
      // CW
      angle += angularSpeed;
      if (angle > 360.0)
        angle -= 360.0;
    } else {
      // CCW
      angle -= angularSpeed;
      if (angle < 0.0)
        angle += 360.0;
    }
    
    _thrust.directionByDegrees = angle;
    
    _exhaustLeftPS.particleActivation.angleDirection = _thrust.asAngleInDegrees + 180.0;
    _exhaustRightPS.particleActivation.angleDirection = _thrust.asAngleInDegrees + 180.0;
    gunPS.particleActivation.angleDirection = _thrust.asAngleInDegrees;
  }
  
  void rotateCWOn() {
    _rotateCWOn = true;
  }
  
  void rotateCWOff() {
    _rotateCWOn = false;
  }
  
  void rotateCCWOn() {
    _rotateCCWOn = true;
  }
  
  void rotateCCWOff() {
    _rotateCCWOn = false;
  }
  
  void setSpeed(double speed) {
    _thrust.speed = speed;
  }
  
  void increaseSpeed() {
    _thrust.increaseSpeed(0.005);
  }
  
  void decreaseSpeed() {
    _thrust.decreaseSpeed(0.002);
  }
  
  void applyThrust() {
    // As thrust is being applied the speed increases but only to a maximum.
    increaseSpeed();
  }
  
  void pulseForceFrom(double duration, double angle, double mag) {
    _pulseOn = true;
    _pulseDuration = duration;
    _pulseAngle = angle;
    _pulseMag = mag;
  }
  
  void thrust(bool onOff) {
    if (onOff) {
      // Thrust on
      _thrust.speed = 0.025;
      _thrustOn = true;
    } else {
      // Thrust off
      _thrust.speed = 0.0;
      _thrustOn = false;
    }
  }

  void fire(bool onOff) {
    if (onOff) {
      // Firing.
      _firing = true;
    } else {
      // Stop firing.
      _firing = false;
    }
  }

}
