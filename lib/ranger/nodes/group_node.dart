part of ranger;

/**
 * [GroupNode] is the core grouping behavior component.
 * 
 *                  [GroupNode]
 *                  /    |    \
 *            child4   child5   child6
 *             / | \
 *      child1 child2 child3
 * 
 * A [GroupNode] can have children. The order in which they are added is the
 * order of traversal. If you want to control the order then change the
 * Z-order value. Smaller values are drawn first, larger values last.
 * Equal values are drawn based on arrival. It is suggested you use
 * unique Z values to control your [GroupNode] rendering order.
 * 
 * A simple parent node designed to contain other nodes with no
 * visible representation of itself other than optional aabbox.
 * TODO calc aabbox of children.
 */
class GroupNode extends Node with GroupingBehavior {
  bool iconVisible = false;
  double iconScale = 1.0;
  
  String outlineColor = Color4IDarkBlue.toString();
  
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  GroupNode._();

  GroupNode();
  
  factory GroupNode.basic() {
    GroupNode poolable = new GroupNode.pooled();
    if (poolable.init()) {
      poolable.initGroupingBehavior(poolable);
      return poolable;
    }
    return null;
  }

  factory GroupNode.pooled() {
    GroupNode poolable = new Poolable.of(GroupNode, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  static GroupNode _createPoolable() => new GroupNode._();

  @override
  GroupNode clone() {
    GroupNode poolable = new GroupNode.pooled();
    if (poolable.init()) {
      return poolable;
    }
    
    return null;
  }
  
  @override
  void draw(DrawContext context) {
    if (iconVisible) {
      context.save();
      context.drawColor = outlineColor;
      double invScale = 1.0 / calcUniformScaleComponent();
      context.lineWidth = invScale;
      context.drawLineByComp(-0.25 * iconScale, 0.25 * iconScale, 0.25 * iconScale, -0.25 * iconScale);
      context.drawLineByComp(-0.25 * iconScale, -0.25 * iconScale, 0.25 * iconScale, 0.25 * iconScale);
      context.restore();
    }
  }

}
