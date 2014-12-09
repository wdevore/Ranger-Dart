part of ranger;

/**
 * A slightly more complex particle system that supports random delays and
 * emission durations.
 */

class ModerateParticleSystem extends ParticleSystem {
  // Delay is in seconds expressed in fractions. ex. 1.0 = 1 second.
  // How long before another batch of particles are emitted.
  Variance delay = new Variance.initWith(0.0, 1.0, 0.5);
  double _delayCount = 0.0;
  double _delay = 0.1;
  bool delayParticles = false;
  
  // Duration controls
  // How long particles are emitted
  double emitterDuration = 0.0;
  double _emitterDurationCount = 0.0;
  bool durationExpired = false;
  bool pauseExpired = false;
  double pauseFor = 0.0;
  double _pauseForCount = 0.0;
  bool _durationEnabled = false;
  
  // Emission rate
  // Values are in [particles per frame].
  // Default is 1 particle per frame = 60 particles per second.
  //Variance emissionRateVar = new Variance.initWith(1.0, 10.0, 3.0);
  int emissionRateCount = 0;
  int emissionRate = 3;
  
  /// If true the ParticleSystem is reset after the pause.
  bool autoReset = false;
  
  // A function for setting emission velocity. The two most common
  // are directional and omni-directional/radial.
  ModerateParticleSystem();
  
  // ----------------------------------------------------------
  // Poolable support and Factories
  // ----------------------------------------------------------
  ModerateParticleSystem._();

  /**
   * Construct a poolable [ModerateParticleSystem]
   * [particles] - Max particles that can spawn.
   */
  factory ModerateParticleSystem.initWith(int maxParticles) {
    ModerateParticleSystem ps = new ModerateParticleSystem._poolable();
    ps.init(maxParticles);
    return ps;
  }

  factory ModerateParticleSystem._poolable() {
    ModerateParticleSystem poolable = new Poolable.of(ModerateParticleSystem, _createPoolable);
    return poolable;
  }

  static ModerateParticleSystem _createPoolable() => new ModerateParticleSystem._();

  set preActivateCallback(Function activateCallback) => _preActivateCallback = activateCallback;

  List<Particle> get particles => _particles;
  
  void add(Particle p) {
    _particles.add(p);
  }
  
  void reset() {
    if (autoReset)
      super.reset();
    _emitterDurationCount = _pauseForCount = 0.0;
    durationExpired = pauseExpired = false;
  }
  
  void addByPrototype(GroupingBehavior parent, Particle prototype, [int quantity]) {
    if (quantity == null)
      quantity = maxParticles;
    
    for(int i = 0; i < quantity; i++) {
      Particle clone = prototype.clone();
      BaseNode visual = clone.visual;
      visual.visible = false;
      parent.addChild(visual);
      _particles.add(clone);
    }
  }
  
  void update(double dt) {
    particleActivation.update(dt);
    
    if (_durationEnabled) {
      _emitterDurationCount += dt;
      if (_emitterDurationCount > emitterDuration) {
        durationExpired = true;
      }
      
      if (durationExpired) {
        _pauseForCount += dt;
        if (_pauseForCount > pauseFor) {
          pauseExpired = true;
        }
      }
      
      if (pauseExpired) {
        reset();
        return;
      }
    }

    if (active) {
      for(Particle p in _particles) {
        if (p.active) {
          p.update(dt);

          if (p.isDead)
            deActivateParticle(p);
        }
      }
    }
  }
  
  bool activateByStyle(int emissionStyle, [double dt = 0.0]) {
    int emitted = 0;
    
    if (!delayParticles) {
      if (!durationExpired) {
        bool e = emit(emissionStyle);
        if (e)
          emitted++;
      }
    }
    else {
      // We are randomly delaying each particle.
      if (_delayCount > _delay) {
        if (!durationExpired) {
          bool e = emit(emissionStyle);
          if (e)
            emitted++;
        }
        _delayCount = 0.0;
        _delay = delay.value;
      }
    }
    
    _delayCount += dt;
    
    return emitted > 0;
  }

  bool emit(int emissionStyle) {
    int emitted = 0;
    do {
      // Continue to emit particles until count maxed.
      emissionRateCount++;
      bool e = _activate(emissionStyle);
      if (e)
        emitted++;
    } while (emissionRateCount < emissionRate);
    
    emissionRateCount = 0;
    
    return emitted > 0;
  }
  
  set durationEnabled(bool enable) {
    if (enable) {
      reset();
    }
    _durationEnabled = enable;
  }
  bool get durationEnabled => _durationEnabled;
  
}