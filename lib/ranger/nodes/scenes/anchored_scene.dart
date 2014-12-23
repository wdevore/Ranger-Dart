part of ranger;

/**
 * [AnchoredScene] is the most common scene you will use. It is designed
 * to be used in conjunction with [TransitionScene]s while at the same
 * time being animatable.
 * 
 * The [Tweenable] implemention is designed to modify the [Scene] or
 * [anchor] according to the animation type. For example, translations
 * modify the [Scene]'s position property and Scale/Rotation modify
 * the [anchor]'s scale and rotation values.
 */
class AnchoredScene extends Scene with UTE.Tweenable {
  static const int TRANSLATE_X = 1;
  static const int TRANSLATE_Y = 2;
  static const int TRANSLATE_XY = 3;
  static const int SCALE_X = 10;
  static const int SCALE_Y = 11;
  static const int SCALE_XY = 12;
  static const int ROTATE = 50;

  Function completeVisitCallback;
  
  /**
   * How long to pause (in seconds) before beginning transition to the [_replacementScene]
   * [Scene]. Default is immediately (aka 0.0)
   */
  double pauseFor = 0.0;
  double _pauseForCount = 0.0;
  bool _pauseComplete = false;
  /// Defaults to disabled
  bool transitionEnabled = false;
  
  AnchoredScene();
  
  AnchoredScene.withPrimaryLayer(Node primary, [Function completeVisit = null]) {
    completeVisitCallback = completeVisit;
    initWithPrimary(primary);
  }
  
  /**
   * [zOrder] and [tag] are applied to the [primary] node.
   */
  bool initWithPrimary(Node primary, [int zOrder = 0, int tag = 0]) {
    primaryLayer = primary;
    
    // Add anchor
    SceneAnchor anchorBase = new SceneAnchor();
    //anchorBase.iconVisible = true;
    addChild(anchorBase, 0, 2525);

    // Bind layer and scene for background constraining.
    if (primaryLayer is Layer || primaryLayer is BackgroundLayer) {
      Layer l = primaryLayer as Layer;
      l.anchoredScene = this;
    }
    else {
      //print("AnchoredScene: warning! primary node tag:${primary.tag} is not of type Layer/BackgroundLayer. The scene will not be anchored to the node provided.");
    }
    
    // Child the primary layer to the anchor.
    anchorBase.addChild(primaryLayer, zOrder, tag);
    
    return true;
  }
  
  @override
  void onEnter() {
    super.onEnter();
    _pauseForCount = 0.0;
    _pauseComplete = false;
    
    scheduleUpdate();
  }

  @override
  void onExit() {
    super.onExit();
    unScheduleUpdate();
  }

  @override
  void update(double dt) {
    if (transitionEnabled) {
      _pauseForCount += dt;
      
      if (_pauseForCount > pauseFor && !_pauseComplete) {
        _pauseComplete = true;
        transition();
      }
    }
  }

  void addLayer(Layer layer, [int zOrder = 0, int tag = 0]) {
    layer.anchoredScene = this;
    if (primaryLayer is GroupingBehavior) {
      GroupingBehavior gb = primaryLayer as GroupingBehavior;
      gb.addChild(layer, zOrder, tag);
    }
  }
  
  /// Override, if necessary, to provide custom transition.
  void transition() {
    
  }
  
  @override
  void completeVisit() {
    if (completeVisitCallback != null)
      completeVisitCallback();
  }
  
  /**
   * Convenience method for setting the anchor with the area of the
   * [Layer]. The anchor can actually be set outside of the visible area
   * for additional types of effects; see [setAnchorBasePosition].
   * 
   * Set the anchor position based on percentage of scene bounds.
   * Note: depending on what [CONFIG.base_coordinate_system] the lower
   * left maybe the upper left.
   * 
   * 0%, 100%             100%, 100%
   *  .----------------------.
   *  |                      |
   *  |                      |
   *  |                      |
   *  |                      |    "left" handed = lower left = 0,0
   *  |                      |
   *  |                      |
   *  |                      |
   *  .----------------------.
   * 0%, 0%               100%, 0%
   */
  void setAnchorPositionByPercent(double px, double py) {
    double width = _contentSize.width;
    double height = _contentSize.height;
    if (primaryLayer != null) {
      width = primaryLayer._contentSize.width;
      height = primaryLayer._contentSize.height;
    }
    
    setAnchorBasePosition(width * (px / 100.0), height * (py / 100.0));
  }
  
  /// Allows the anchor to positioned anywhere.
  void setAnchorBasePosition(double x, double y) {
    // The anchor is translating by a delta-vector not absolutely translating.
    // Calc delta before we set the new anchor position.
    double dx = x - anchor.position.x;
    double dy = y - anchor.position.y;
    
    // Now actually translate anchor.
    anchor.setPosition(x, y);
    
    // Translate layer inversely relative to parent anchor.
    primaryLayer.moveByComp(-dx, -dy);
  }

  int getTweenableValues(UTE.Tween tween, int tweenType, List<num> returnValues) {
//    print("AnchoredScene.getTweenableValues: tag:$tag, $tweenType, $returnValues");
    switch (tweenType) {
      case TRANSLATE_X:
        returnValues[0] = position.x;
        return 1;
      case TRANSLATE_Y:
        returnValues[0] = position.y;
        return 1;
      case TRANSLATE_XY:
        returnValues[0] = position.x;
        returnValues[1] = position.y;
        return 2;
      case ROTATE:
        returnValues[0] = anchor.rotationInDegrees;
        return 1;
      case SCALE_X:
        returnValues[0] = anchor.scale.x;
        return 1;
      case SCALE_Y:
        returnValues[0] = anchor.scale.y;
        return 1;
      case SCALE_XY:
        returnValues[0] = anchor.scale.x;//target.scale.x;
        returnValues[1] = anchor.scale.y;//target.scale.y;
        return 2;
    }
    
    return 0;
  }
  
  void setTweenableValues(UTE.Tween tween, int tweenType, List<num> newValues) {
//    print("AnchoredScene.setTweenableValues: tag:$tag, $tweenType, $newValues");
    switch (tweenType) {
      case TRANSLATE_X:
        setPosition(newValues[0], position.y);
        break;
      case TRANSLATE_Y:
        setPosition(position.x, newValues[0]);
        break;
      case TRANSLATE_XY:
        setPosition(position.x, anchor.position.y);
        break;
      case ROTATE:
        anchor.rotationByDegrees = newValues[0];
        break;
      case SCALE_X:
        anchor.scale.x = newValues[0];
        anchor.dirty = true;
        break;
      case SCALE_Y:
        anchor.scale.y = newValues[0];
        anchor.dirty = true;
        break;
      case SCALE_XY:
        anchor.scale.x = newValues[0];
        anchor.scale.y = newValues[1];
        anchor.dirty = true;
        break;
    }
  }
}
