part of ranger;

/** 
 * TODO not yet complete.
 * [LayerCascade] is a subclass of [Layer].
 * It adds color management to child [Layer]s.
 */
class LayerCascade extends Layer with RGBACascadeMixin {
  /**
   * Centers world-space into the center of the Design-space.
   */
  bool centered = false;

  LayerCascade();
  
  bool init([int width, int height]) {
    if (super.init(width, height)) {
      if (initCascadeBehavior(parent, children)) {
        return super.init();
      }
    }
    
    return false;
  }
  
  void release() {
    super.release();
  }
  
  /*
   * We override parent property to keep behaviors in sync.
   */
  @override
  set parent(BaseNode parent) {
    super.parent = _behaviorParent = parent;
  }
  
  @override
  set children(List<BaseNode> children) {
    super.children = _behaviorChildren = children;
  }
  
  @override
  void addChild(BaseNode node, [int zOrder = 0, int tag = 0]) {
    super.addChild(node, zOrder, tag);
    
    if (_cascadeColorEnabled)
      cascadeColorEnabled = true;
    
    if (_cascadeOpacityEnabled)
      cascadeOpacityEnabled = true;
  }
  
  // ----------------------------------------------------------
  // Opacity
  // ----------------------------------------------------------
  /// implementation for [RGBAInterface]
  int get opacity => _realColor.a;
  
  /**
   * Override synthesized setOpacity to recurse through Layer hiearchy.
   * [opacity] ranges from 0 -> 255.
   * implementation for [RGBAInterface]
   */
  set opacity(int opacity) {
    _displayedColor.a = _realColor.a = opacity;
    
    int parentOpacity = 255;
    
    if (parent != null && parent is RGBACascadeMixin) {
      RGBACascadeMixin parentLayer = parent as RGBACascadeMixin;
      if (parentLayer.cascadeOpacityEnabled) {
        parentOpacity = parentLayer.displayedOpacity;
      }
    }
    cascadeOpacity(parentOpacity);
  }
  
  // ----------------------------------------------------------
  // Color
  // ----------------------------------------------------------
  /// implementation for [RGBAInterface]
  Color4<int> get color => _realColor;

  /**
   * If cascasding is enabled then children's colors are set as well.
   * Alpha is ignored. Use [opacity].
   * implementation for [RGBAInterface]
   */
  set color(Color4<int> c) {
    _displayedColor.r = _realColor.r = c.r;
    _displayedColor.g = _realColor.g = c.g;
    _displayedColor.b = _realColor.b = c.b;
    _displayedColor.a = _realColor.a = c.a;
    
    if (parent != null && parent is RGBACascadeMixin) {
      RGBACascadeMixin parentLayer = parent as RGBACascadeMixin;
      if (parentLayer.cascadeColorEnabled) {
        cascadeColor(parentLayer.displayedColor);
      }
      else {
        Color4<int> whiteColor = Color4IWhite;
        cascadeColor(whiteColor);
        whiteColor.moveToPool();
      }
    }
  }

}

