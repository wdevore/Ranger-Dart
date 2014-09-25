part of ranger;

/**
 * [SimpleParticle] controls a single [BaseNode]'s
 * position and rotation behavior.
 */
class SimpleParticle extends PositionalParticle with ParticleRotationBehavior {
  // ----------------------------------------------------------
  // Poolable support and Factories
  // ----------------------------------------------------------
  SimpleParticle._();
  
  /**
   * Construct a poolable [SimpleParticle]
   * [node] - The affected node by this particle.
   */
  factory SimpleParticle.withNode(BaseNode node) {
    SimpleParticle p = new SimpleParticle._poolable();
    
    p.initWithNode(node);
    
    return p;
  }

  factory SimpleParticle._poolable() {
    SimpleParticle poolable = new Poolable.of(SimpleParticle, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  static SimpleParticle _createPoolable() => new SimpleParticle._();

  SimpleParticle clone() {
    // First clone the visual
    BaseNode nodeClone = node.clone();
    
    // Now create a new particle behavior that will affect the cloned visual.
    SimpleParticle p = new SimpleParticle.withNode(nodeClone);
    
    p.initWithRotation(0.0, 0.0, rate);
    
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

      if (node is Color4Mixin) {
        Color4Mixin cm = node as Color4Mixin;
        cm.color.setWith(pd.startColor);
      }
      
      _acceleration = pd.acceleration;
      rate = pd.rotationRate;
      node.uniformScale = pd.startScale;
      
      activateWithVelocityAndLife(pd.velocity, pd.lifespan);
    }
    else {
      // TODO throw exception
      print("!!!!!!!! Particle data not present");
    }

    super.activateAt(x, y);
 }

  void step(double time) {
    super.step(time);
    
    stepRotationBehavior(time);
    node.rotationByDegrees = angle;
    
  }

}