part of ranger;

/**
 * [NodeWithSkew] adds skewing transformations.
 */

abstract class NodeWithSkew extends BaseNode with SkewBehavior {
  NodeWithSkew clone() {
    return null;
  }
  
  bool init() {
    if (super.init()) {
      initWithSkewComponents(this, 0.0, 0.0);
      return true;
    }
    
    return false;
  }
  
  bool initWith(NodeWithSkew node) {
    if (super.initWith(node)) {
      initWithSkewComponents(this, node.skew.x, node.skew.y);
      return true;
    }
    
    return false;
  }
  

  /**
   * Returns a matrix that transforms the [NodeWithSkew]'s local-space coordinates
   * to the [NodeWithSkew]'s parent-space coordinates.
   */
  AffineTransform calcTransform() {
    bool dirty = _transformDirty; // Capture current dirty value.
    
    super.calcTransform();
    
    if (dirty) {
      if (skew.x != 0.0 || skew.y != 0.0) {
        transform.skew(skew.x, skew.y);
      }
    }

    return transform;
  }

}