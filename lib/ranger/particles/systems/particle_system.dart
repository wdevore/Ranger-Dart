part of ranger;

/**
 * Particle System (PS).
 * A PS is a collection of particles.
 * A particle system (PS) will emit 2 states:
 *  1) Activate
 *  2) Deactivate
 * PS determines when a particle is to be activated but it doesn't activate
 * the particle itself. Activation is done by a ParticleActivator (PA).
 * The PA generates the "from" properties prior to activating the particle
 * and then activates it.
 * The Behaviors are what modifies the properties over time.
 *  
 *  Particles can be affected by external forces such as Gravity, Winds
 *  Vortexs etc..
 *  
 *  A particle can have 1 or more Shapes/Nodes that it affects. A Node
 *  always renders itself, but the properties of the Node are affected
 *  by the particle because a particle is a behavior that acts upon
 *  a Node. For example, as the particle lives it may change
 *  the Node's color based on the life time value.
 *
 *  ColorParticle:
 *    This changes the Node's color based time.
 *  AlphaParticle:
 *    This changes the opacity overtime.
 *    
 *  Particles should be able to use the Animations for control. Should be
 *  able to use ColorTo to control color.
 *  Particles have a normalized life time that ranges from 0.0 -> 1.0.
 *  When time reaches 1.0 the particle has died.
 *   
 *  As a particle dies it is placed back in the pool.
 *  
 *  When the PS is released all the associated particles are removed from
 *  the pool collection.
 *  
 *  PS are configured through json maps.
 */

abstract class ParticleSystem extends ComponentPoolable with TimingTarget {
  int maxParticles = 10;
  ParticleSystemVisual emitterVisual;
  
  // When a particle dies it is removed from this collection and placed
  // back in the pool.
  List<Particle> _particles = new List<Particle>();
  
  bool active = false;
  int activeParticles = 0;

  math.Random _randGen = new math.Random();
  
  Function _preActivateCallback;
  
  ParticleActivation particleActivation;
  
  // A function for setting emission velocity. The two most common
  // are directional and omni-directional/radial.
  ParticleSystem();
  
  set preActivateCallback(Function activateCallback) => _preActivateCallback = activateCallback;

  void init(int maxParticles) {
    emitterVisual = new ParticleSystemVisual.withPS(this);
    emitterVisual.tag = 77;
    //emitterVisual.visible = false;
    this.maxParticles = maxParticles;
  }
  
  void setPosition(double x, double y) {
    emitterVisual.setPosition(x, y);
  }
  
  List<Particle> get particles => _particles;
  
  bool get isActive => _particles.where((Particle p) => p.active).length > 0;
  
  void add(Particle p) {
    _particles.add(p);
  }
  
  void reset() {
    _particles.forEach((Particle p) => deActivateParticle(p));
  }
  
  /**
   * [prototype] is typically something like [UniversalParticle].
   */
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
  
  void update(double dt);
  
  bool get particlesAvailable => activeParticles < _particles.length;
  
  Particle get nextAvailableParticle => _particles.firstWhere((Particle p) => !p.active, orElse: () => null);
  
  bool activateByStyle(int emissionStyle, [double dt = 0.0]);

  void explodeByStyle(int emissionStyle) {
    activeParticles = 0;

    for(Particle p in _particles) {
      activateByStyle(emissionStyle);
    }
  }
  
  bool _activate(int emissionStyle) {
    if (particleActivation != null) {
      if (particlesAvailable) {
        Particle p = nextAvailableParticle;
        if (p != null) {
          activeParticles++;

          if (_preActivateCallback != null)
            _preActivateCallback(p);
          
          particleActivation.activate(p, emissionStyle, emitterVisual.position.x, emitterVisual.position.y);
          return true;
        }
      }
    }
    else {
      print("ParticleSystem: warning! A particle activator is not assigned. Particles can not be activated.");
    }
    
    return false;
  }
  
  void emit(int emissionStyle);
  
  double _genValueFrom(double min, double max, double variance, double mean) {
    // The "value" must stay > 0 including the variance. The variance
    // can +-. It is a max swing centering around the Min.
    // min + Mean * (max - min)
    //
    //
    //   max --------------------------------------------
    //                 .       .    .
    //           ...       ..
    //   --------------------------------------------  distribution epic center
    //              ..   .   .   ..
    //                .            .
    //   min --------------------------------------------
    //
    //   0.0 --------------------------------------------
    //double mean = (max - min) / 2.0;
    double epic = min + mean * (max - min);
    
    double swing = _randGen.nextDouble() * variance;
    swing = _randGen.nextDouble() > 0.5 ? -swing : swing;
    double value = epic + swing;
    
    value = math.min(max, value);
    value = math.max(min, value);
    return value;
  }
  
  int _genIntValueFrom(int min, int max, int variance, double mean) {
    // The "value" must stay > 0 including the variance. The variance
    // can +-. It is a max swing centering around the Min.
    // min + Mean * (max - min)
    //
    //
    //   max --------------------------------------------
    //                 .       .    .
    //           ...       ..
    //   --------------------------------------------  distribution epic center
    //              ..   .   .   ..
    //                .            .
    //   min --------------------------------------------
    //
    //   0.0 --------------------------------------------
    //double mean = (max - min) / 2.0;
    double epic = min + mean * (max - min);
    
    double swing = _randGen.nextDouble() * variance;
    swing = _randGen.nextDouble() > 0.5 ? -swing : swing;
    double value = epic + swing;
    
    value = math.min(max.toDouble(), value);
    value = math.max(min.toDouble(), value);
    return value.floor();
  }
  
  void deActivateParticle(Particle p) {
    particleActivation.deactivate(p);
    p.deActivate();
    activeParticles--;
    activeParticles = activeParticles < 0 ? 0 : activeParticles;
  }

  /**
   * if [repool] is true(Default) then the particles are moved back to the
   * pool prior to removal.
   */
  void release([bool repool = true]) {
    if (repool)
      _particles.forEach((Particle p) => p.moveToPool());
    _particles.clear();
  }
}