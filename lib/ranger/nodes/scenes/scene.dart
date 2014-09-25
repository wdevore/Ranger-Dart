part of ranger;

/**
 * [Scene] is a subclass of [Node]. It is used only as an abstract concept.
 * [AnchoredScene] and [Scene] are almost identical with the difference
 * that [AnchoredScene] has an internal structure to accomodate an anchor,
 * a point (by default) at the corner of the screen, and
 * depending on what [CONFIG.base_coordinate_system] is set as, the corner
 * could be in the lower-left or upper-left.
 * 
 * A [Scene] scene's lifetime is controlled by the [SceneManager].
 * For the moment [Scene] has no other logic than that. 
 *
 * A [Scene] always has a "primary" layer where all the visual nodes are
 * located.
 * We also bind the [Scene] to the [Layer] in order to constrain the
 * background relative to the anchor.
 * Finally we tell the scene what the primaryLayer is.
 * 
 * Example usage:
 * TestLayer layer = new TestLayer.withColor(Ranger.color4IFromHex("#ffaadd77"));
 * layer.anchoredScene = scene;
 *
 * scene.primaryLayer = layer;
 */
abstract class Scene extends Node with GroupingBehavior {
  Node _primaryLayer;
  
  Scene() {
    if (init()) {
      Application app = Application.instance;
      setContentSize(app.viewSize.width.toDouble(), app.viewSize.height.toDouble());
    }
  }

  bool init() {
    if (super.init()) {
      initGroupingBehavior(this);
      
      drawOrder = 0;
      return true;
    }
    
    return false;
  }

  SceneAnchor get anchor => _children[0] as SceneAnchor;
  
  set primaryLayer(Node l) => _primaryLayer = l;
  Node get primaryLayer => _primaryLayer;
}