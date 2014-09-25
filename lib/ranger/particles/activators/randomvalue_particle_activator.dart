part of ranger;

/**
 * An example of an activator that generates values based on a
 * mean/variance line.
 */
class RandomValueParticleActivator extends ParticleActivation {
  // -----------------------------------------------------
  // Life
  // -----------------------------------------------------
  Variance lifespan = new Variance.initWith(1.0, 2.0, 1.0);

  // -----------------------------------------------------
  // Acceleration
  // -----------------------------------------------------
  Variance acceleration = new Variance.initWith(1.0, 5.0, 2.5);

  // -----------------------------------------------------
  // Speed
  // -----------------------------------------------------
  Variance speed = new Variance.initWith(1.0, 5.0, 2.5);
  double speedDamping = 2.5;

  // -----------------------------------------------------
  // Scale
  // -----------------------------------------------------
  Variance startScale = new Variance.initWith(5.0, 25.0, 10.0);
  Variance endScale = new Variance.initWith(5.0, 25.0, 10.0);
  bool syncSpeedToScale = false;

  // -----------------------------------------------------
  // Rotation rate
  // -----------------------------------------------------
  // This property is Time based.
  Variance rotationRate = new Variance.initWith(-10.0, 10.0, 10.0);

  // -----------------------------------------------------
  // Color
  // -----------------------------------------------------
  Color4<int> startColor = Color4IBlue;
  Color4<int> endColor = Color4IOrange;
  Color4<int> varianceColor = Color4IWhite;
  Color4<int> meanColor = Color4IWhite;
  
  Variance delay = new Variance.initWith(0.0, 0.0, 0.0);
  
  static UTE.TweenManager tweenMan = new UTE.TweenManager();

  RandomValueParticleActivator() {
    minSpeed = 1.0;
    maxSpeed = 5.0;
  }
  
  double get minSpeed => activationData.velocity.minMagnitude;
  set minSpeed(double v) {
    activationData.velocity.minMagnitude = speed.min = v;
  }
  double get maxSpeed => activationData.velocity.maxMagnitude;
  set maxSpeed(double v) {
    activationData.velocity.maxMagnitude = speed.max = v;
  }

  void update(double dt) {
    tweenMan.update(dt);
    lifespan.update(dt);
    acceleration.update(dt);
    speed.update(dt);
    startScale.update(dt);
    endScale.update(dt);
    rotationRate.update(dt);
  }
  
  void activate(Particle particle, int emissionStyle, double posX, double posY) {
    
    _genValues(particle, activationData);
    
    switch(emissionStyle) {
      case ParticleActivation.UNI_DIRECTIONAL: // Uni Directional (straight line)
        activationData.velocity.directionByDegrees = angleDirection;
        break;
      case ParticleActivation.OMNI_DIRECTIONAL: // Omni Directional (sparkler effect)
        activationData.velocity.directionByDegrees = _randGen.nextDouble() * 359.0;
        break;
      case ParticleActivation.DRIFT_DIRECTIONAL: // Drift Directional (spray hose effect)
        double variance = _randGen.nextDouble() * angleVariance;
        variance = _randGen.nextDouble() > 0.5 ? -variance : variance;
        double angle = activationData.velocity.asAngleInDegrees + variance;

        activationData.velocity.directionByDegrees = angle;
        break;
      case ParticleActivation.VARIANCE_DIRECTIONAL: // Variance Directional (rocket exhaust effect)
        double variance = _randGen.nextDouble() * angleVariance;
        variance = _randGen.nextDouble() > 0.5 ? -variance : variance;
        double angle = angleDirection + variance;

        activationData.velocity.directionByDegrees = angle;
        break;
      case ParticleActivation.PINGPONG_DIRECTIONAL: // PingPong Variance Directional
        // Sweep angle back and forth stopping when reached angleVariance.
        double delta = (sweepAngle.abs() - angleDirection.abs()).abs();
        
        if (delta > angleVariance) {
          sweepAngleRate = -sweepAngleRate;
        }
        
        sweepAngle += sweepAngleRate;

        activationData.velocity.directionByDegrees = sweepAngle;
        break;
      case ParticleActivation.RADIALSWEEP_DIRECTIONAL: // RadialSweep Variance Directional
        sweepAngle = (sweepAngle + sweepAngleRate) % 360;
        activationData.velocity.directionByDegrees = sweepAngle;
        break;
    }

    // Pass the activation data along with the particle about to be
    // activated.
    particle.data = activationData;
    
    // Notify callee that a particle is going to be activated and where.
    if (activateCallback != null)
      activateCallback(particle, posX, posY);

    // Now that the particle is configured we can finally
    // activate it, most likely with the PositionalParticle's implementation
    particle.activateAt(posX, posY);
  }

  void _genValues(Particle particle, ActivationData data) {
    // Calculate "from/starting/launching" values
    data.lifespan = lifespan.value;
    data.startScale = startScale.value;
    data.endScale = endScale.value;
    //print("RandomValueParticleActivator._genValues: endScale:${data.endScale}");
    data.rotationRate = rotationRate.value;
    data.acceleration = acceleration.value;
    //print("RandomValueParticleActivator._genValues: acceleration:${data.acceleration}");
    data.delay = delay.value;
    
    data.speed = speed.value;
    if (syncSpeedToScale)
      data.speed /= (data.startScale - data.endScale).abs() / speedDamping;
    
    data.startColor.setWith(startColor);
    data.endColor.setWith(endColor);
  }
  
  void deactivate(Particle particle) {
    if (deactivateCallback != null)
      deactivateCallback(particle);
  }
  
}