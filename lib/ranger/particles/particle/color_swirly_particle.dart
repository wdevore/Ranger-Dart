part of ranger;

/**
 * OUT OF DATE!!!
 * [ColorSwirlyParticle] controls a single [BaseNode]'s position and color.
 * It tint's a [BaseNode]'s color channel based on lifespan.
 */
class ColorSwirlyParticle {
  Vector2 _displacment = new Vector2.zero();
  Vector2 _direction = new Vector2.zero();
  double _angle = 0.0;
  double _frequency = 1.0;
  double _originalSteppingRate = 0.0;
  double _angleSteppingRate = 10.0;
  bool _squiggle = false;
  double _amplitude = 1.0;
  bool _randomDirection = false;
  math.Random _randGen;

  // ----------------------------------------------------------
  // Poolable support and Factories
  // ----------------------------------------------------------
  ColorSwirlyParticle();
  
  ColorSwirlyParticle._();
  
  /**
   * Construct a poolable [ColorSwirlyParticle]
   * [lifespan] - Lifespan of particle.
   * [node] - The node affected by this particle. BaseNode also supplies the "from"
   * color.
   * [toColor] the destination color.
   * [angleSteppingRate] in degrees. High degrees the more swirl life effect.
   * [frequency] how big the swirl is.
   * [amplitude] how big a swing.
   * [randomDirection]
   * [squiggle] controls if the swirl is compounding. This produces some
   * crazy motion.
   */
//  factory ColorSwirlyParticle.withLifeAndNode(double lifespan, BaseNode node, Color4<int> toColor, double angleSteppingRate, double amplitude, [double frequency = 1.0, bool randomDirection = true, bool squiggle = false]) {
//    ColorSwirlyParticle p = new ColorSwirlyParticle._poolable();
////    p.init();
////    p.initWithLifeAndNode(lifespan, node);
////    p.initWithColor(toColor);
//    p._angleSteppingRate = p._originalSteppingRate = angleSteppingRate;
//    p._frequency = frequency;
//    p._amplitude = amplitude;
//    p._squiggle = squiggle;
//    p._randomDirection = randomDirection;
//    p._randGen = new math.Random();
//    return p;
//  }
//
//  factory ColorSwirlyParticle._poolable() {
//    ColorSwirlyParticle poolable = new Poolable.of(ColorSwirlyParticle, _createPoolable);
//  poolable.pooled = true;
//    return poolable;
//  }
//
//  static ColorSwirlyParticle _createPoolable() => new ColorSwirlyParticle._();
//
//  ColorSwirlyParticle clone() {
//    BaseNode nodeClone = node.clone();
//    ColorSwirlyParticle ps = new ColorSwirlyParticle.withLifeAndNode(lifespan, nodeClone, toColor, _frequency, _amplitude);
//    return ps;
//  }
  
  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
//  @override
//  void activate(double x, double y, Velocity velocity, double lifespan) {
//    super.activate(x, y, velocity, lifespan);
//    if (_randomDirection) {
//      double n = _randGen.nextDouble();
//      if (n < 0.5)
//        _angleSteppingRate = degreesToRadians(_originalSteppingRate);
//      else
//        _angleSteppingRate = -degreesToRadians(_originalSteppingRate);
//    }
//  }
//
//  @override
//  void step(double time) {
//    Vector2 position = node.position;
//    
//    // Remove previous displacement effect. By not removing the effect
//    // the particle appears to Swirl in spiral like patterns.
//    if (!_squiggle)
//      position.sub(_displacment);
//    
//    // Now Step
//    super.step(time);
//    
//    _angle += _angleSteppingRate;
//    
//    _direction.setValues(_frequency * math.cos(_angle), _frequency * math.sin(_angle));
//    _displacment.setValues(_amplitude * _direction.x, _amplitude * _direction.y);
//    position.add(_displacment);
//    node.dirty = true;
//  }

}