part of unittests;

class RectangleNode extends Ranger.Node {
  String drawColor;
  String fillColor;
  
  double outlineThickness = 3.0;

  /** 
   * [RectangleNode] default to unit sized. One reason to
   * transform it is if you don't want (or didn't apply) affine transforms which
   * would cause modified context effects.
   * For example, if the context has been scaled then outlines would be
   * scaled as well.
   * If you didn't want that effect you would scale this [rect] instead.
   * In other words there is two ways you can affect the [RectangleNode]:
   * 1) use the [Node]'s transform or
   * 2) change the [rect]'s properties.
   */
  Ranger.MutableRectangle<double> rect = new Ranger.MutableRectangle<double>(0.0, 0.0, 0.0, 0.0);
  
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  RectangleNode();
  
  /**
   * [image] is a resource previously loaded by a resource loader.
   * [centered] defaults to True.
   */
  factory RectangleNode.basic() {
    RectangleNode poolable = new RectangleNode.pooled();
    if (poolable.init()) {
      poolable.rect.setValues(0.0, 0.0, 0.0, 0.0);
      poolable.size = 1.0;
      poolable.initWithUniformScale(poolable, 1.0);
      return poolable;
    }
    return null;
  }

  RectangleNode._();
  factory RectangleNode.pooled() {
    RectangleNode poolable = new Ranger.Poolable.of(RectangleNode, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  static RectangleNode _createPoolable() => new RectangleNode._();

  RectangleNode clone() {
    RectangleNode poolable = new RectangleNode.pooled();
    poolable.initWith(this);
    poolable.size = size;
    poolable.fillColor = fillColor;
    poolable.drawColor = drawColor;
    poolable.rect.setWith(rect);
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

    context.fillColor = fillColor;
    context.drawColor = drawColor;
    
    double invScale = 1.0 / calcUniformScaleComponent() * outlineThickness;
    context.lineWidth = invScale;

    context.drawRect(rect.left, rect.bottom, rect.width, rect.height);
    
    context.restore();
  }
}
