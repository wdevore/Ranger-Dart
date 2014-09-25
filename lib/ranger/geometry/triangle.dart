part of ranger;

class Triangle extends Polygon {
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  Triangle._();
  
  /// [Triangle] points along the +X axis.
  factory Triangle.elongated() {
    Triangle poolable = new Poolable.of(Triangle, _create);
    poolable.points.add(new Vector2(1.0, 0.0));  // upper middle
    poolable.points.add(new Vector2(-1.0, -0.707));  // lower left
    poolable.points.add(new Vector2(-1.0, 0.707));  // lower right
    poolable.calcAABBox();
    return poolable;
  }

  /// Creates a [Poolable] center normalized triangle.
  factory Triangle.centered() {
    Triangle poolable = new Poolable.of(Triangle, _create);
    // Defined CCW in a +Y upward system.
    poolable.points.add(new Vector2(0.707, 0.0));  // upper middle
    poolable.points.add(new Vector2(-0.707, -0.707));  // lower left
    poolable.points.add(new Vector2(-0.707, 0.707));  // lower right
    poolable.calcAABBox();
    return poolable;
  }

  static Triangle _create() => new Triangle._();
}

