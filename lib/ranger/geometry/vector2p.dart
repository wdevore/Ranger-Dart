part of ranger;

/**
 * A poolable class that wraps [Vector2]. Most of the space mapping
 * methods return this object.
 * When you are finished with it you move it back to the pool.
 * 
 *     Ranger.Vector2P ws = convertToWorldSpace(location);
 *      // Now convert it into GameLayer-space.
 *     Ranger.Vector2P ns = _gameLayer.convertWorldToNodeSpace(ws.v);
 *
 *     // Clean up.
 *     ns.moveToPool();
 *     ws.moveToPool();
 *
 */
class Vector2P extends ComponentPoolable {
  Vector2 v = new Vector2.zero();
  
  // ----------------------------------------------------------
  // Poolable support and Factories
  // ----------------------------------------------------------
//  Vector2P();
  
  Vector2P._();

  /**
   * Construct a poolable [RotateTo]
   * [duration] is in seconds.
   * [deltaAngle] is in Degrees;
   */
  factory Vector2P() {
    Vector2P c = new Vector2P._poolable();
    return c;
  }

  factory Vector2P.withCoords(double x, double y) {
    Vector2P c = new Vector2P._poolable();
    c.v.setValues(x, y);
    return c;
  }

  factory Vector2P._poolable() {
    Vector2P poolable = new Poolable.of(Vector2P, _createPoolable);
    return poolable;
  }

  static Vector2P _createPoolable() => new Vector2P._();

}