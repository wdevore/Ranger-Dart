part of ranger_rocket;

/**
 * This may be a mixin.
 */
class ZoomGroup extends Ranger.GroupNode {

  bool _zoomDirty = true;
  Vector2 _scaleCenter = new Vector2.zero();
  
  Ranger.AffineTransform atSCTransform = new Ranger.AffineTransform.Identity();
  
  ZoomGroup._();

  factory ZoomGroup.basic() {
    ZoomGroup poolable = new ZoomGroup.pooled();
    if (poolable.init()) {
      poolable.initGroupingBehavior(poolable);
      poolable.atSCTransform.toIdentity();
      poolable.updateMatrix();
      poolable.tag = 606;
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

//  void transform(BaseNode node) {
//    AffineTransform t = node.calcTransform();
//    context.transform(t.a, t.b, t.c, t.d, t.tx, t.ty);
//  }

  void updateMatrix() {
    if (_zoomDirty) {
      Ranger.AffineTransform scaleCenter = new Ranger.AffineTransform.asTranslate(_scaleCenter.x, _scaleCenter.y);
      Ranger.AffineTransform scaleTransform = new Ranger.AffineTransform.asScale(scale.x, scale.y);
      Ranger.AffineTransform negScaleCenter = new Ranger.AffineTransform.asTranslate(-_scaleCenter.x, -_scaleCenter.y);
      
      // Accumulate zoom transformations.
      // atSCTransform is an intermediate matrix used for tracking the current zoom target.
      atSCTransform.concatenate(scaleCenter);
      atSCTransform.concatenate(scaleTransform);
      atSCTransform.concatenate(negScaleCenter);
      
      // We reset Scale because atSCTransform is accumulative.
//      uniformScale = 1.0;
      scale.setValues(1.0, 1.0);
      
      Ranger.AffineTransform atTransform = new Ranger.AffineTransform.asTranslate(position.x, position.y);
  
      // Tack on translation. Note: we don't append it on but concat it into a separate matrix.
      // We want to leave atSCTransform solely responsible for zooming.
      // transform is the final matrix used for space-mapping.
      transform.setWithAT(atSCTransform);
      transform.concatenate(atTransform);
      print("updateMatrix:\n${transform}");
      
      // Now that we have rebuilt the transform matrix is it no longer dirty.
      _zoomDirty = false;
      
      // Note!!: Because this node manages its own matrix we mark this Node as NOT dirty,
      // as we don't want calls to worldToNode... and nodeToWorld... to overwrite our matrix.
      dirty = false;
    }
  }
  
  @override
  bool visit(Ranger.DrawContext context) {
//    print("visit:\n${transform}");
    return super.visit(context);
  }
  
  void zoomBy(double delta) {
    scale.setValues(scale.x + delta, scale.y + delta);
    //uniformScale = uniformScale + delta;
    //dirty = false;
    _zoomDirty = true;
    updateMatrix();
    print("zoomBy:\n${transform}, dirty:${dirty}");
  }
  
  void translateBy(Vector2 delta) {
    position.add(delta);
    _zoomDirty = true;
    updateMatrix();
  }
  
  /// Override [PositionalBehavior]'s setter
  @override
  set position(Vector2 position) {
    super.position = position;
    node.dirty = true;
  }

  
}