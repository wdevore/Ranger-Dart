part of unittests;

class SquareParticleNode extends Ranger.Node with Ranger.Color4Mixin {
  /** 
   * [SquareParticleNode] default to unit sized. One reason to
   * transform it is if you don't want (or didn't apply) affine transforms which
   * would cause modified context effects.
   * For example, if the context has been scaled then outlines would be
   * scaled as well.
   * If you didn't want that effect you would scale this [rect] instead.
   * In other words there is two ways you can affect the [SquareParticleNode]:
   * 1) use the [Node]'s transform or
   * 2) change the [rect]'s properties.
   */
  Ranger.MutableRectangle<double> rect = new Ranger.MutableRectangle<double>(0.0, 0.0, 0.0, 0.0);
  
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  SquareParticleNode();
  
  /**
   * [image] is a resource previously loaded by a resource loader.
   * [centered] defaults to True.
   */
  factory SquareParticleNode.basic() {
    SquareParticleNode poolable = new SquareParticleNode.pooled();
    if (poolable.init()) {
      poolable.rect.setValues(0.0, 0.0, 0.0, 0.0);
      poolable.size = 1.0;
      poolable.initWithUniformScale(poolable, 1.0);
      return poolable;
    }
    return null;
  }

  SquareParticleNode._();
  factory SquareParticleNode.pooled() {
    SquareParticleNode poolable = new Ranger.Poolable.of(SquareParticleNode, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  static SquareParticleNode _createPoolable() => new SquareParticleNode._();

  SquareParticleNode clone() {
    SquareParticleNode poolable = new SquareParticleNode.pooled();
    if (poolable.initWith(this)) {
      poolable.size = size;
      poolable.rect.setWith(rect);
    }
    return poolable;
  }

  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  void center() {
    rect.left = rect.left - (rect.width / 2.0);
    rect.bottom = rect.bottom - (rect.height / 2.0);
  }
  
  set size(double s) {
    rect.width = s;
    rect.height = s;
  }

  double get size => rect.width;
  
  bool containsPoint(Vector2 p) {
    return rect.containsPointByComp(p.x, p.y);
  }
  
  @override
  void draw(Ranger.DrawContext context) {
    context.save();

    context.fillColor = color.toString();
    
    context.drawRect(rect.left, rect.bottom, rect.width, rect.height);
    
    context.restore();
  }
}
