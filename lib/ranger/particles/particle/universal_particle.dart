part of ranger;

/**
 * [UniversalParticle] controls a single [BaseNode]'s
 * position, color, scale and rotation.
 */
class UniversalParticle extends PositionalParticle with ParticleScaleBehavior, ParticleColorBehavior, ParticleRotationBehavior {
  // ----------------------------------------------------------
  // Poolable support and Factories
  // ----------------------------------------------------------
  UniversalParticle._();
  
  /**
   * Construct a poolable [UniversalParticle]
   * [node] - The affected node by this particle.
   */
  factory UniversalParticle.withNode(BaseNode node) {
    UniversalParticle p = new UniversalParticle._poolable();
    
    p.initWithNode(node);
    
    return p;
  }

  factory UniversalParticle._poolable() {
    UniversalParticle poolable = new Poolable.of(UniversalParticle, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  static UniversalParticle _createPoolable() => new UniversalParticle._();

  UniversalParticle clone() {
    // First clone the visual
    BaseNode nodeClone = node.clone();
    
    // Now create a new particle behavior that will affect the cloned visual.
    UniversalParticle p = new UniversalParticle.withNode(nodeClone);
    
    // Copy the properties from this particle to the cloned version.
    p.initWithColor(fromColor, toColor);
    
    p.initWithRotation(fromRotation, toRotation);
    
    p.initWithScale(fromScale, toScale);
    
    p.interpolate = interpolate;
    p.rate = rate;
    return p;
  }
  
  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  /**
   * [activateAt] requires that the particle's [data] property
   * be populated otherwise an Exception is thrown. 
   */
  @override
  void activateAt(double x, double y) {
    // Take the activation values and configure the behaviors.

    if (data != null) {
      ActivationData pd = data as ActivationData;

      fromColor.setWith(pd.startColor);
      toColor.setWith(pd.endColor);
      
      rate = pd.rotationRate;
      fromScale = pd.startScale;
      toScale = pd.endScale;
      _acceleration = pd.acceleration;
      
      activateWithVelocityAndLife(pd.velocity, pd.lifespan);
    }
    else {
      throw new Exception("UniversalParticle: Error! Particle data not present.");
    }

    super.activateAt(x, y);
 }

  void step(double time) {
    super.step(time);
    
    stepColorBehavior(time);
    if (node is Color4Mixin) {
      Color4Mixin cb = node as Color4Mixin;
      cb.color.setWith(color);
    }
    
    stepScaleBehavior(time);
    node.uniformScale = scale;
    
    stepRotationBehavior(time);
    node.rotationByDegrees = angle;
  }

}