part of ranger;

/**
 * A simple particle system. For a more complex system is
 * [ModerateParticleSystem].
 */

class BasicParticleSystem extends ParticleSystem {
  // Emission rate
  // Values are in [particles per frame].
  // Default is 1 particle per frame = 60 particles per second.
  // We could adjust the rate every N seconds.
  //Variance emissionRateVar = new Variance.initWith(1.0, 10.0, 3.0);
  int emissionRateCount = 0;
  int emissionRate = 1;
  
  // ----------------------------------------------------------
  // Poolable support and Factories
  // ----------------------------------------------------------
  BasicParticleSystem._();

  /**
   * Construct a poolable [ParticleSystem]
   * [particles] - Max particles that can spawn.
   */
  factory BasicParticleSystem.initWith(int maxParticles) {
    BasicParticleSystem ps = new BasicParticleSystem._poolable();
    ps.init(maxParticles);
    return ps;
  }

  factory BasicParticleSystem._poolable() {
    BasicParticleSystem poolable = new Poolable.of(BasicParticleSystem, _createPoolable);
    return poolable;
  }

  static BasicParticleSystem _createPoolable() => new BasicParticleSystem._();

  void activateByStyle(int emissionStyle, [double dt = 0.0]) {
    emit(emissionStyle);
  }

  void update(double dt) {
    particleActivation.update(dt);
    
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

  @override
  void explodeByStyle(int emissionStyle) {
    activeParticles = 0;
    for(Particle p in _particles) {
      activateByStyle(emissionStyle);
    }
  }

  void emit(int emissionStyle) {
    do {
      // Continue to emit particles until count maxed.
      emissionRateCount++;
      _activate(emissionStyle);
    } while (emissionRateCount < emissionRate);
    
    emissionRateCount = 0;
  }
  
}