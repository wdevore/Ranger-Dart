part of ranger;

/**
 * A very trivial particle value generator and activator.
 */
class SimpleParticleActivator extends ParticleActivation {
  Color4<int> color = Color4IOrange;
  
  SimpleParticleActivator() {
    minSpeed = 1.0;
    maxSpeed = 5.0;
  }
  
  double get minSpeed => activationData.velocity.minMagnitude;
  set minSpeed(double v) => activationData.velocity.minMagnitude = v;
  double get maxSpeed => activationData.velocity.maxMagnitude;
  set maxSpeed(double v) => activationData.velocity.maxMagnitude = v;

  void activate(Particle particle, int emissionStyle, double posX, double posY) {
    
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

  void deactivate(Particle particle) {
    if (deactivateCallback != null)
      deactivateCallback(particle);
  }
  

}