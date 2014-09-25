part of ranger;

/** 
 * [Layer] is a subclass of [Node] that mixes in Grouping behavior and
 * input functionality.
 * All features from [Node] are valid.
 */
class Layer extends Node with GroupingBehavior {
  /**
   * Used to constrain the background if present.
   * See [BackgroundLayer] as an example.
   */
  AnchoredScene anchoredScene;
  
  Layer();
  
  @override
  bool init([int width, int height]) {
    if (super.init()) {
      initGroupingBehavior(this);

      Application app = Application.instance;
      
      if (width != null && height != null)
        initLayer(width, height);
      else
        initLayer(app.designSize.width.toInt(), app.designSize.height.toInt());
      
      return true;
    }
    
    return false;
  }
  
  void initLayer(int width, int height) {
    setContentSize(width.toDouble(), height.toDouble());
  }
  
  @override
  void cleanup([bool cleanUp = true]) {
    //Logging.info("Layer.cleanup: $tag");
    super.cleanup(cleanUp);
  }
  
  /**
   * This is called when ever a [Layer] just becomes visible.
   * Meaning it is visible and the visibility just happened.
   */
  @override
  void onEnter() {
    // TODO register accelerometer
    
    super.onEnter();
  }
  
  @override
  void onExit() {
    //Application app = Application.instance;

    // TODO register accelerometer
    
    super.onExit();
    
  }

  /**
   * This is called when ever a [Layer] is a child of a [Scene] has just
   * finished a transition.
   */
  @override
  void onEnterTransitionDidFinish() {
    //if (isAccelerometerEnabled && cc.Accelerometer)
    //  add accelerometer delegate.
    super.onEnterTransitionDidFinish();
  }
  
}

