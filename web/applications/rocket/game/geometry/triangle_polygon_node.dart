part of ranger_rocket;

class TrianglePolygonNode extends PolygonNode with Ranger.VisibilityBehavior {
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  TrianglePolygonNode._();
  
  factory TrianglePolygonNode() {
    TrianglePolygonNode poolable = new TrianglePolygonNode.pooled();
    if (poolable.init()) {
      poolable.polygon = new Ranger.Triangle.centered();
      return poolable;
    }
    return null;
  }

  factory TrianglePolygonNode.pooled() {
    TrianglePolygonNode poolable = new Ranger.Poolable.of(TrianglePolygonNode, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  static TrianglePolygonNode _createPoolable() => new TrianglePolygonNode._();

  @override
  TrianglePolygonNode clone() {
    TrianglePolygonNode poolable = new TrianglePolygonNode.pooled();
    if (poolable.init()) {
      poolable.initWith(this);
      poolable.fillColor = fillColor;
      poolable.solid = solid;
      poolable.outlined = outlined;
      poolable.drawColor = drawColor;
      return poolable;
    }
    
    return null;
  }

}
