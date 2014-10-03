part of ranger_rocket;

class PointColor extends Ranger.Node {
  String outlineColor;
  String fillColor;
  
  double outlineThickness = 3.0;

  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  PointColor();
  
  PointColor._();
  factory PointColor.pooled() {
    PointColor poolable = new Ranger.Poolable.of(PointColor, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  factory PointColor.initWith(Ranger.Color4<int> fillColor, [Ranger.Color4<int> outlineColor, double fromScale = 1.0]) {
    PointColor poolable = new PointColor.pooled();
    if (poolable.init()) {
      if (fillColor != null)
        poolable.fillColor = fillColor.toString();
      if (outlineColor != null)
        poolable.outlineColor = outlineColor.toString();
      poolable.initWithUniformScale(poolable, fromScale);
      return poolable;
    }
    return null;
  }
  
  static PointColor _createPoolable() => new PointColor._();

  PointColor clone() {
    PointColor poolable = new PointColor.pooled();
    
    if (poolable.initWith(this)) {
      poolable.fillColor = fillColor;
      poolable.outlineColor = outlineColor;
      poolable.initWithUniformScale(poolable, 1.0);
      return poolable;
    }
    
    return null;
  }
  
  /*
   * The node passed could be of any shape. If it is a square then we
   * do a point in rect. if point then no collision ever.
   * if polygon the point in polygon.
   */
  @override
  bool collide(Ranger.Node node) {
    if (node is PointColor) {
      return false;
    }
    
    if (node is PolygonNode) {
      return node.pointInside(position);
    }
    
//    bool collide = collideByPoint(node.position);
    bool collide = _inCircle(
        node.position.x,
        node.position.y,
        uniformScale, 
        position.x, position.y
        );
      
    return collide;
  }
  
  bool collideByPoint(Vector2 point) {
    bool collide = _inCircle(
        point.x,
        point.y,
        uniformScale, 
        position.x, position.y
        );
    
    return collide;
  }
  
  bool _inCircle(double x, double y, double radius, double cx, double cy) { 
    double dx = cx - x;
    double dy = cy - y;
    dx *= dx;
    dy *= dy;
    double distanceSquared = dx + dy;
    double radiusSquared = radius * radius;
    return distanceSquared <= radiusSquared;  
  }

  bool _inCircle2(double x, double y, double radius, double cx, double cy) {
    double ddx = (x - cx)*(x - cx);
    double ddy = (y - cy)*(y - cy); 
    double sqt = sqrt((ddx + ddy));
    bool collide = sqt < radius;
    return collide;
  }
  
  @override
  void draw(Ranger.DrawContext context) {
    context.save();

    context.fillColor = fillColor;
    context.drawColor = outlineColor;
    
    double invScale = 1.0 / calcUniformScaleComponent() * outlineThickness;
    context.lineWidth = invScale;

    context.drawPointAt(0.0, 0.0);

    context.restore();

    Ranger.Application.instance.objectsDrawn++;
  }

}
