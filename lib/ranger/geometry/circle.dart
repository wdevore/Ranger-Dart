part of ranger;

class Circle extends Polygon {
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  Circle._();
  
  factory Circle.withSegments(int segments) {
    Circle poolable = new Poolable.of(Circle, _createPoolable);
    // Defined CCW in a +Y upward system.

    final double theta_inc = 2.0 * math.PI / segments;
    double theta = 0.0;
    if (segments == 3)
        theta = -math.PI / 6.0;
    else if (segments > 3)
        theta = -math.PI / 4.0;
    
    for (int i = 0; i < segments; i++) {
      double x = math.cos(theta) / 2.0;
      double y = math.sin(theta) / 2.0;

      poolable.points.add(new Vector2(x, y));
        
      theta += theta_inc;
    }

    poolable.calcAABBox();

    return poolable;
  }

  static Circle _createPoolable() => new Circle._();
}

