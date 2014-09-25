part of ranger;

class Square extends Polygon {
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  Square._();
  
  factory Square() {
    Square poolable = new Poolable.of(Square, _createPoolable);
    // Defined CCW in a +Y upward system.
    poolable.points.add(new Vector2(0.0, 0.0));
    poolable.points.add(new Vector2(1.0, 0.0));
    poolable.points.add(new Vector2(1.0, 1.0));
    poolable.points.add(new Vector2(0.0, 1.0));
    poolable.calcAABBox();
    return poolable;
  }

  factory Square.centered() {
    Square poolable = new Poolable.of(Square, _createPoolable);
    // Defined CCW in a +Y upward system.
    poolable.points.add(new Vector2(-0.5, -0.5));
    poolable.points.add(new Vector2(0.5, -0.5));
    poolable.points.add(new Vector2(0.5, 0.5));
    poolable.points.add(new Vector2(-0.5, 0.5));
    poolable.calcAABBox();
    return poolable;
  }

  static Square _createPoolable() => new Square._();
}

