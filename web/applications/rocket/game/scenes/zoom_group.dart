part of ranger_rocket;

/**
 * This may be a mixin.
 */
class ZoomGroup extends Ranger.GroupNode {

  bool _zoomDirty = true;
  Vector2 scaleCenter = new Vector2.zero();
  bool zoomIconVisible = false;
  
  Ranger.AffineTransform atSCTransform = new Ranger.AffineTransform.Identity();
  Ranger.AffineTransform zoomCenter = new Ranger.AffineTransform.Identity();
  Ranger.AffineTransform scaleTransform = new Ranger.AffineTransform.Identity();
  Ranger.AffineTransform negScaleCenter = new Ranger.AffineTransform.Identity();
  Ranger.AffineTransform atTransform = new Ranger.AffineTransform.Identity();

  ZoomGroup._();

  factory ZoomGroup.basic() {
    ZoomGroup poolable = new ZoomGroup.pooled();
    if (poolable.init()) {
      poolable.initGroupingBehavior(poolable);
      poolable.atSCTransform.toIdentity();
      poolable._updateMatrix();
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

  void _updateMatrix() {
    if (_zoomDirty) {
      zoomCenter.setToTranslate(scaleCenter.x, scaleCenter.y);
      scaleTransform.setToScale(scale.x, scale.y);
      negScaleCenter.setToTranslate(-scaleCenter.x, -scaleCenter.y);
      
      // Accumulate zoom transformations.
      // atSCTransform is an intermediate accumulative matrix used for tracking the current zoom target.
      Ranger.affineTransformMultiplyTo(zoomCenter, atSCTransform);
      Ranger.affineTransformMultiplyTo(scaleTransform, atSCTransform);
      Ranger.affineTransformMultiplyTo(negScaleCenter, atSCTransform);
      
      // We reset Scale because atSCTransform is accumulative.
      scale.setValues(1.0, 1.0);
      
      // Tack on translation. Note: we don't append it, but concat it into a separate matrix.
      // We want to leave atSCTransform solely responsible for zooming.
      // transform is the final matrix for this node.
      atTransform.setToTranslate(position.x, position.y);
  
      transform.multiply(atSCTransform, atTransform);
      
      // Now that we have rebuilt the transform matrix is it no longer dirty.
      _zoomDirty = false;
    }
  }
  
//  /**
//   * This method does the same update as [updateMatrix] except it uses
//   * static methods and is slight less efficient.
//   * It is here just as an example.
//   */
//  void _updateMatrix2() {
//    if (_zoomDirty) {
//      Ranger.AffineTransform zoomCenter = new Ranger.AffineTransform.asTranslate(scaleCenter.x, scaleCenter.y);
//      Ranger.AffineTransform scaleTransform = new Ranger.AffineTransform.asScale(scale.x, scale.y);
//      Ranger.AffineTransform negScaleCenter = new Ranger.AffineTransform.asTranslate(-scaleCenter.x, -scaleCenter.y);
//      
//      // Accumulate zoom transformations.
//      // atSCTransform is an intermediate matrix used for tracking the current zoom target.
//      Ranger.AffineTransform m1 = Ranger.affineTransformMultiply(zoomCenter, atSCTransform);
//      Ranger.AffineTransform m2 = Ranger.affineTransformMultiply(scaleTransform, m1);
//      Ranger.AffineTransform m3 = Ranger.affineTransformMultiply(negScaleCenter, m2);
//      atSCTransform.setWithAT(m3);
//      
//      zoomCenter.moveToPool();
//      scaleTransform.moveToPool();
//      negScaleCenter.moveToPool();
//
//      // We reset Scale because atSCTransform is accumulative.
//      scale.setValues(1.0, 1.0);
//      
//      Ranger.AffineTransform atTransform = new Ranger.AffineTransform.asTranslate(position.x, position.y);
//  
//      Ranger.AffineTransform m4 = Ranger.affineTransformMultiply(m3, atTransform);
//      atTransform.moveToPool();
//
//      // Tack on translation. Note: we don't append it on but concat it into a separate matrix.
//      // We want to leave atSCTransform solely responsible for zooming.
//      // transform is the final matrix used for space-mapping.
//      transform.setWithAT(m4);
//      print("updateMatrix:\n${transform}");
//      
//      m1.moveToPool();
//      m2.moveToPool();
//      m3.moveToPool();
//      m4.moveToPool();
//      
//      // Now that we have rebuilt the transform matrix is it no longer dirty.
//      _zoomDirty = false;
//
//      // TODO This shouldn't be needed. To be deprecated.
//      // Note!!: Because this node manages its own matrix we mark this Node as NOT dirty,
//      // as we don't want calls to worldToNode... and nodeToWorld... to overwrite our matrix.
//      //dirty = false;
//    }
//  }
  
  /**
   * A relative zoom.
   * [delta] is a delta relative to the current scale/zoom.
   */
  void zoomBy(double delta) {
    scale.setValues(scale.x + delta, scale.y + delta);
    _zoomDirty = true;
    _updateMatrix();
  }
  
  /**
   * Not typically used unless you want to translate the layer. Typically
   * you would set the [scaleCenter] instead of this position.
   * It is provide simply for convienience.
   */
  void translateBy(Vector2 delta) {
    position.add(delta);
    _zoomDirty = true;
    _updateMatrix();
  }
  
  /**
   * Overrides [PositionalBehavior]'s setter
   * Not typically used unless you want to translate the layer. Typically
   * you would set the [scaleCenter] instead of this position.
   * It is provide simply for convienience.
   */
  @override
  set position(Vector2 pos) {
    position.setFrom(pos);
    _zoomDirty = true;
    _updateMatrix();
  }

  /**
   * Set the zoom value absolutely. If you want to zoom relative use
   * [zoomBy]
   */
  set currentScale(double newScale) {
      // We use dimensional anaylsis to set the scale. Remember we can't
      // just set the scale absolutely because atSCTransform is an accumulating matrix.
      // We have to take its current value and compute a new value based
      // on the passed in value.
      
      // Also, I can use atSCTransform.a because I don't allow rotation on this
      // layer so the diagonal components correctly represent the matrix's current scale.
      // And because I only perform uniform scaling I can safely use just the "a" element.
      double scaleFactor = newScale / atSCTransform.a;
      
      scale.setValues(scaleFactor, scaleFactor);

      _zoomDirty = true;
      
      _updateMatrix();
  }
  
  double get currentScale => atSCTransform.a;

  @override
  void draw(Ranger.DrawContext context) {
    super.draw(context);
    if (zoomIconVisible) {
      context.save();
      context.drawColor = Ranger.Color4IWhite.toString();
      
      double invScale = 1.0 / calcUniformScaleComponent();
      context.lineWidth = invScale;
      
      context.drawLineByComp(-1.0 * iconScale + scaleCenter.x, scaleCenter.y, 1.0 * iconScale + scaleCenter.x, scaleCenter.y);
      context.drawLineByComp(scaleCenter.x, -1.0 * iconScale + scaleCenter.y, scaleCenter.x, 1.0 * iconScale + scaleCenter.y);
      
      context.restore();
    }
  }
}