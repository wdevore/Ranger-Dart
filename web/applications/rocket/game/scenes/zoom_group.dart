part of ranger_rocket;

/**
 * This may be a mixin.
 */
class ZoomGroup extends Ranger.GroupNode {

  ZoomGroup._();

  factory ZoomGroup.basic() {
    ZoomGroup poolable = new ZoomGroup.pooled();
    if (poolable.init()) {
      poolable.initGroupingBehavior(poolable);
      return poolable;
    }
    return null;
  }

  factory ZoomGroup.pooled() {
    ZoomGroup poolable = new Ranger.Poolable.of(Ranger.GroupNode, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  static ZoomGroup _createPoolable() => new ZoomGroup._();
  
  @override
  void updateTransform() {
    super.updateTransform();
  }
}