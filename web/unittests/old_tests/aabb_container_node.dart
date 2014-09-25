library containerLibtests;

import 'package:ranger/ranger.dart' as Ranger;
import 'scenes_and_nodes.dart';

/**
 * A [AABBContainerNode] is special in that it syncs it's positional information
 * with a "lead" child [Node].
 * When the child is translated the translation actually happens to the
 * container and not the child. Rotation and Scales are passed to the
 * "lead".
 * This allows siblings and the "lead" to maintain the same positional
 * space.
 */
class AABBContainerNode extends Ranger.Node with Ranger.GroupingBehavior {
  AABBNode aabbNode;

  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  AABBContainerNode() {
  }
  
  factory AABBContainerNode.withLead(PolygonNode lead, [PolygonNode listenTo = null]) {
    AABBContainerNode poolable = new AABBContainerNode.pooled();
    if (poolable.init()) {
      poolable.initGroupingBehavior(poolable);
      
      poolable.addChild(lead, 13, 909);
      if (listenTo == null)
        poolable.aabbNode = new AABBNode.listenTo(lead);
      else
        poolable.aabbNode = new AABBNode.listenTo(listenTo);
      // aabbNode needs to be a sibling.
      poolable.addChild(poolable.aabbNode, 11, 501);
      
      return poolable;
    }
    
    return null;
  }

  AABBContainerNode._();
  
  /// Don't call this directly unless you know how to initialize the
  /// Node correctly.
  factory AABBContainerNode.pooled() {
    AABBContainerNode poolable = new Ranger.Poolable.of(AABBContainerNode, _createPoolable);
    poolable.init();
    return poolable;
  }

  static AABBContainerNode _createPoolable() => new AABBContainerNode._();

  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  void release() {
    aabbNode.release();
  }
}

/*
 * This Node listens to another node for dirty changes and updates itself
 * when that node's dirty state changes.
 */
class AABBNode extends Ranger.Node {
  String drawColor = Ranger.Color4IBlue.toString();
  Ranger.MutableRectangle<double> rect;
  double uScale = 1.0;
  PolygonNode listeningTo;
  Ranger.AffineTransform at = new Ranger.AffineTransform.IdentityP();
  Ranger.MutableRectangle<double> rect1 = new Ranger.MutableRectangle<double>(0.0, 0.0, 0.0, 0.0);

  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  AABBNode() {
  }
  
  AABBNode._();
  
  factory AABBNode.listenTo(Ranger.Node node) {
    AABBNode poolable = new AABBNode.pooled();
    poolable.listeningTo = node;
    node.addDirtyListener(poolable);
    return poolable;
  }

  factory AABBNode.pooled() {
    AABBNode poolable = new Ranger.Poolable.of(AABBNode, _createPoolable);
    poolable.init();
    return poolable;
  }

  static AABBNode _createPoolable() => new AABBNode._();

  void dirtyChanged(Ranger.Node node) {
    rect = node.calcParentAABB();
    at.setWithAT(node.parent.calcTransform());
    uScale = node.nodeToParentScale();
  }
  
  void release() {
    listeningTo.removeDirtyListener(this);
  }
  
  @override
  void draw(Ranger.DrawContext context) {
    if (rect != null) {
      context.lineWidth = 1.0 / at.extractUniformScale();
      if (at != null) {
        context.transformWith(at);
      }
      
      context.drawColor = drawColor;
      context.drawRect(rect.left, rect.bottom, rect.width, rect.height);
    }
  }

}

