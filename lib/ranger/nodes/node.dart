part of ranger;

/**
 * [Node] provides basic implementations for [BaseNode]. You will always
 * inherit from this class when creating nodes.
 */
abstract class Node extends BaseNode {
  List<BaseNode> _dirtySubscribers = new List<BaseNode>();
  
  MutableRectangle<double> rect = new MutableRectangle<double>(0.0, 0.0, 0.0, 0.0);

  bool intersectsViewPort = false;
  
//  Aabb2 aabbox = new Aabb2();

  bool init() {
    if (super.init()) {
      
      drawOrder = 0;
  
      return true;
    }
    
    return false;
  }

  bool initWith(Node node) {
    if (super.initWith(node)) {

      drawOrder = node.drawOrder;
      
      return true;
    }
    
    return false;
  }

  @override
  Node clone() {
    return null;
  }

  /**
   * Implement if you want your [Node] notified when another Node has
   * become dirty from a transformation being applied.
   */
  void dirtyChanged(Node node) {
    _dirtySubscribers.forEach((Node n) => n.dirtyChanged(node));
  }

  void addDirtyListener(Node node) {
    _dirtySubscribers.add(node);
  }
  
  void removeDirtyListener(Node node) {
    _dirtySubscribers.remove(node);
  }
  
  @override
  void release() {
    
  }
  
//  /**
//   * [p] should be in node's local-space.
//   */
//  bool containsPoint(Vector2 p) {
//    return localBounds.containsVector2(p);
//  }

//  Aabb2 get localBounds {
//    aabbox.min.setValues(rect.left, rect.top);
//    aabbox.max.setValues(rect.right, rect.bottom);
//    return aabbox;
//  }
  
  @override
  bool isVisible() {
    // checkVisibility is typically implemented by a mixin/behavior.
    // If not then BaseNode supplies a default behavior of reflecting
    // the current state which means you don't need an actual Rectangle
    // to calculate that, hence the "null" parameter value.
    bool intersects = checkVisibility(null);
    
    return intersects;
  }

  /**
   * Override this method to provide collision checks against other
   * [Node]s.
   * Each [Node] should supply its own check. For example, a Circle shaped
   * node may do a radius check, where as a Square shaped [Node] would
   * may perform a bounding box check.
   */
  bool collide(Node node) {
    return false;
  }
  
  //-------------------------------------------------------------------
  // Life Cycles
  //-------------------------------------------------------------------
  @override
  void onEnter() {
    // This method will either be BaseNode's method or a mixin/behavior.
    // This is the same for all on.... methods.
    onEnterNode();
  }

  @override
  void onExitTransitionDidStart() {
    onExitTransitionDidStartNode();
  }

  @override
  void onEnterTransitionDidFinish() {
    onEnterTransitionDidFinishNode();
  }

  @override
  void onExit() {
    onExitNode();
  }

  @override
  void cleanup([bool cleanUp = true]) {
    cleanUpNode(cleanUp);    
  }

  @override
  void updateTransform() {
    // Generally a Mixin provides functionality.
    updateTransforms();
  }

  @override
  bool visit(DrawContext context) {
    return visitNode(context);
  }
  
  set dirty(bool dirty) {
    dirtyNode = dirty;
  }
  
  /**
   * Implement if you want to know when your [Node] was added as a child
   * to some other parent.
   */
  @override
  void addedAsChild() {
    
  }

  /**
   * Remove this [Node] from its parent [Node] which implies that the
   * parent has grouping behavior.
   * If [cleanUp] is true, then remove all animations and schedule targets.
   * If the [cleanUp] is not passed, it will force a cleanup.
   * If the [Node] is a Leaf, then nothing happens.
   */
  void removeFromParent([bool cleanUp = true]) {
    if (_parent != null && _parent is GroupingBehavior) {
      GroupingBehavior gb = _parent as GroupingBehavior;
      gb.removeChild(this, cleanUp);
    }
  }

  /// Default is to draw nothing. In essence an invisible node.
  /// Consider setting the [Node] invisible to save unnecessary work if
  /// your design allows.
  @override
  void draw(DrawContext context) {
    
  }

  /**
   * Iterate through this [Node]'s children accumulating local AABBoxes.
   * An AABBox only needs to be recomputed if a [Node] becomes dirty.
   */
  @override
  MutableRectangle<double> calcParentAABB() {
    return null;
  }
  
  /**
   * Calculates and returns this [Node]'s world-space
   * axis aligned bounding box (AABB). It iterates through this [Node]'s
   * children accumulating boxes.
   * If the [Node] has no children then the aabbox is simply this [Node]'s
   * size.
   * The [Node]'s aabbox is set by the Node itself as it knows best how
   * to do that.
   * 
   * Returns a [Poolable] object. Be sure to move it back to the pool when
   * done with it.
   */
  MutableRectangle<double> calcAABBToWorld() {
    return null;
  }
  
  @override
  bool pointInside(Vector2 point) {
    return false;
  }
}


