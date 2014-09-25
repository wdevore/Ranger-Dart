part of ranger;

/**
 * The [SceneAnchor] is a plane node that draws a diamond shape as a
 * symbol of itself. It is the anchor of an [AnchoredScene].
 */
class SceneAnchor extends Node with GroupingBehavior {
  bool iconVisible = false;
  Color4<int> drawColor = Color4IBlack;
  
  
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  SceneAnchor._();
  
  factory SceneAnchor() {
    SceneAnchor poolable = new SceneAnchor.pooled();
    if (poolable.init()) {
      poolable.initGroupingBehavior(poolable);
      return poolable;
    }
    return null;
  }

  factory SceneAnchor.pooled() {
    SceneAnchor poolable = new Poolable.of(SceneAnchor, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  static SceneAnchor _createPoolable() => new SceneAnchor._();

  @override
  SceneAnchor clone() {
    SceneAnchor poolable = new SceneAnchor.pooled();
    if (poolable.init()) {
      return poolable;
    }
    
    return null;
  }
  
  SceneAnchor get anchor => _children[0] as SceneAnchor;

  @override
  void draw(DrawContext context) {
    if (iconVisible) {
      context.save();
      context.drawColor = drawColor.toString();
      context.lineWidth = 3.0;
      context.drawLineByComp(0.0, 10.25, 10.25, 0.0);
      context.drawLineByComp(10.25, 0.0, 0.0, -10.25);
      context.drawLineByComp(0.0, -10.25, -10.25, 0.0);
      context.drawLineByComp(-10.25, 0.0, 0.0, 10.25);
      context.lineWidth = 1.0;
      context.restore();
    }
  }

}
