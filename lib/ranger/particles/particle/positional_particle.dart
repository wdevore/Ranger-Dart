part of ranger;

/**
 * [PositionalParticle] controls a single [Node]'s position.
 * It does nothing to the [Node]'s visual aspect.
 */
class PositionalParticle extends Particle {
  Node node;
  double _acceleration = 0.0;
  
  // ----------------------------------------------------------
  // Poolable support and Factories
  // ----------------------------------------------------------
  PositionalParticle();

  /**
   * Construct a poolable [PositionalParticle]
   * [lifespan] - Lifespan of particle.
   * [node] - The affected by this particle.
   */
  factory PositionalParticle.withLifeAndNode(double lifespan, Node node) {
    PositionalParticle ps = new PositionalParticle._poolable();
    ps.initWithLifeAndNode(lifespan, node);
    return ps;
  }

  factory PositionalParticle._poolable() {
    PositionalParticle poolable = new Poolable.of(PositionalParticle, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  static PositionalParticle _createPoolable() => new PositionalParticle();

  PositionalParticle clone() {
    PositionalParticle ps = new PositionalParticle._poolable();
    Node visualClone = node.clone();
    ps.initWithLifeAndNode(lifespan, visualClone);
    return ps;
  }
  
  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  Node get visual => node;
  double get acceleration => _acceleration;
  set acceleration(double a) => _acceleration = a;
  
  bool initWithNode(Node node) {
    if (super.initWithLifespan(0.0)) {
      this.node = node;
      return true;
    }
    return false;
  }

  bool initWithLifeAndNode(double lifespan, Node node) {
    if (super.initWithLifespan(lifespan)) {
      this.node = node;
      return true;
    }
    return false;
  }

  void step(double time) {
    velocity.accelerate(_acceleration);
    velocity.applyTo(node.position);
    node.dirty = true;
  }

  @override
  void activateAt(double x, double y) {
    node.setPosition(x, y);
    node.visible = true;
  }
  
  @override
  void activate(double x, double y, Velocity velocity, double lifespan) {
    activateWithVelocityAndLife(velocity, lifespan);
    node.setPosition(x, y);
    node.visible = true;
  }
  
  @override
  void deActivate() {
    super.deActivate();
    node.visible = false;
  }
}