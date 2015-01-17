part of ranger;

/**
 * [EmptyNode]s are generally used as targets for other nodes or as
 * anchor points for rotation and scaling. For example, an [EmptyNode]
 * could act as the center of mass of a space ship.
 */
class EmptyNode extends Node {
  bool iconVisible = false;
  String drawColor = "rgb(0,0,0)";
  
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  EmptyNode._();
  
  factory EmptyNode() {
    EmptyNode poolable = new EmptyNode.pooled();
    if (poolable.init()) {
      return poolable;
    }
    return null;
  }

  factory EmptyNode.pooled() {
    EmptyNode poolable = new Poolable.of(EmptyNode, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  static EmptyNode _createPoolable() => new EmptyNode._();

  @override
  EmptyNode clone() {
    EmptyNode poolable = new EmptyNode.pooled();
    if (poolable.init()) {
      return poolable;
    }
    
    return null;
  }
  
  @override
  void draw(DrawContext context) {
    if (iconVisible) {
      context.save();
      context.drawColor = drawColor;
      double invScale = 1.0 / calcUniformScaleComponent();
      context.lineWidth = invScale;
      context.drawLineByComp(-0.25, 0.25, 0.25, -0.25);
      context.drawLineByComp(-0.25, -0.25, 0.25, 0.25);
      context.restore();
    }
  }

}
