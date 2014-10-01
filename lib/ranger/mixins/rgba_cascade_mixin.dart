part of ranger;

/** 
 * [RGBACascadeMixin] is a Mixin.
 * This Behavior adds cascading of color and opacity both to parent
 * and children.
 * 
 * What ever class you mix this behaviour with (mixed class) you will
 * need to set the [_behaviorChildren] based on the mixed class's children.
 */
abstract class RGBACascadeMixin {
  Color4<int> _displayedColor = Color4IWhite;
  Color4<int> _realColor = Color4IWhite;
  
  bool _cascadeOpacityEnabled = false;
  bool _cascadeColorEnabled = false;
  
  List<BaseNode> _behaviorChildren;
  BaseNode _behaviorParent;
  
  /**
   * [parent] is the parent [BaseNode] to upward iterate towards.
   * [children] are the children to downward iterate towards.
   */
  bool initCascadeBehavior(BaseNode parent, List<BaseNode> children) {
    _behaviorParent = parent;
    _behaviorChildren = children;
    _cascadeOpacityEnabled = false;
    _cascadeColorEnabled = false;
    return true;
  }
  
  void release() {
    _displayedColor.moveToPool();
    _realColor.moveToPool();
  }

  int get displayedOpacity => _displayedColor.a;
  Color4<int> get displayedColor => _displayedColor;

  // ----------------------------------------------------------
  // Opacity
  // ----------------------------------------------------------
  void cascadeOpacity(int opacity) {
    // Update this node's opacity.
    _displayedColor.a = (_realColor.a * opacity) ~/ 255;

    if (_behaviorChildren != null && _cascadeOpacityEnabled) {
      // Traverse each cascade child layer setting their opacity.
      for(BaseNode node in _behaviorChildren) {
        if (node is Color4Mixin) {
          Color4Mixin behavior = node as Color4Mixin;
          behavior.opacity = _displayedColor.a;
        }        
      }
    }
  }
  
  /// Enable/disable this [Layer]'s opacity. If cascasding is enabled
  /// then children are Enable/disabled as well.
  void set cascadeOpacityEnabled(bool enable) {
    _cascadeOpacityEnabled = enable;
    
    if (_cascadeOpacityEnabled) {
      _enableCascadingOfOpacity();
    }
    else {
      _disableCascadingOfOpacity();
    }
  }
  bool get cascadeOpacityEnabled => _cascadeOpacityEnabled;

  void _enableCascadingOfOpacity() {
    int parentOpacity = 255;
    if (_behaviorParent != null && _behaviorParent is RGBACascadeMixin) {
      RGBACascadeMixin parentLayer = _behaviorParent as RGBACascadeMixin;
      if (parentLayer.cascadeOpacityEnabled) {
        parentOpacity = parentLayer.displayedOpacity;
      }
    }
    cascadeOpacity(parentOpacity);
  }
  
  void _disableCascadingOfOpacity() {
    for(BaseNode child in _behaviorChildren) {
      if (child is RGBACascadeMixin) {
        RGBACascadeMixin behavior = child as RGBACascadeMixin;
        behavior._disableCascadingOfOpacity();
      }        
    }
  }
  
  // ----------------------------------------------------------
  // Color
  // ----------------------------------------------------------
  void cascadeColor(Color4<int> color) {
    _displayedColor.r = (_realColor.r * color.r) ~/ 255;
    _displayedColor.g = (_realColor.g * color.g) ~/ 255;
    _displayedColor.b = (_realColor.b * color.b) ~/ 255;
    
    if (_cascadeColorEnabled) {
      for(BaseNode node in _behaviorChildren) {
        if (node is Color4Mixin) {
          Color4Mixin behavior = node as Color4Mixin;
          behavior.initialColor = _displayedColor;
        }        
      }
    }
  }

  void set cascadeColorEnabled(bool enable) {
    _cascadeColorEnabled = enable;
    
    if (_cascadeColorEnabled) {
      _enableCascadingOfColor();
    }
    else {
      _disableCascadingOfColor();
    }
  }
  bool get cascadeColorEnabled => _cascadeColorEnabled;
  
  /// Cascade "upward"s toward parents.
  void _enableCascadingOfColor() {
    // If this node has a parent then iterate upwards
    if (_behaviorParent != null && _behaviorParent is RGBACascadeMixin) {
      RGBACascadeMixin parentLayer = _behaviorParent as RGBACascadeMixin;
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
  
  void _disableCascadingOfColor() {
    // Restore real/original color into displayed color.
    _displayedColor.r = _realColor.r;
    _displayedColor.g = _realColor.g;
    _displayedColor.b = _realColor.b;
    
    // Propagate to children.
    for(BaseNode child in _behaviorChildren) {
      if (child is RGBACascadeMixin) {
        RGBACascadeMixin behavior = child as RGBACascadeMixin;
        behavior._disableCascadingOfColor();
      }        
    }
  }
}

