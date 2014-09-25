part of ranger;

/** 
 * [VisibilityBehavior] is a mixin.
 * Mix with a [Node] that you want visibility behavior.
 * It will override the [BaseNode]'s checkVisibility behavior.
 */
abstract class VisibilityBehavior {
  
  /// This is method will "override" [BaseNode]'s functionality.
  bool checkVisibility(MutableRectangle<double> aabbox, [MutableRectangle<double> viewport]) {
    bool intersects = false;
    
    if (viewport == null) {
      Application app = Application.instance; 
  
      intersects = app.viewPortWorldAABB.intersects(aabbox);
    }
    else {
      intersects = viewport.intersects(aabbox);
    }
    
    return intersects;
  }
  
}

