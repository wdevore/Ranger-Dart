part of ranger_rocket;

class SquarePolygonNode extends PolygonNode with Ranger.VisibilityBehavior {
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  SquarePolygonNode._();
  
  factory SquarePolygonNode() {
    SquarePolygonNode poolable = new SquarePolygonNode.pooled();
    if (poolable.init()) {
      poolable.polygon = new Ranger.Square.centered();
      return poolable;
    }
    return null;
  }

  factory SquarePolygonNode.pooled() {
    SquarePolygonNode poolable = new Ranger.Poolable.of(SquarePolygonNode, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  static SquarePolygonNode _createPoolable() => new SquarePolygonNode._();

  @override
  SquarePolygonNode clone() {
    SquarePolygonNode poolable = new SquarePolygonNode.pooled();
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
