part of ranger;

/**
 * Instantly pop to the next [Scene] after a pause.
 */
class TransitionInstant extends TransitionScene {
  TransitionInstant();
  // Option #2
  //Vector2 prevPos = new Vector2.zero();
  
  /**
   * [duration] is in seconds
   * [scene] is the [Scene] to transition to.
   */
  factory TransitionInstant.initWithScene(BaseNode scene) {
    TransitionInstant tScene = new TransitionInstant();
    tScene.initWithDuration(0.0, scene);
    return tScene;
  }
  
  @override
  void onEnter() {
    super.onEnter();
    
    Application app = Application.instance;

    // We have two choices:
    // 1) make the Scene invisible (probably the better choice for
    //    this transition) or
    // 2) Move the Scene out of view.
    
    // Option #1
    inScene.visible = false;

    // Option #2
    // Capture position before moving out of view.
    //prevPos.setFrom(position);
    // At this point the incoming scene is visible. So we move it out
    // of view. In this case way off to the left.
    //inScene.setPosition(-app.designSize.width, 0.0);
    
    app.animations.callFunc(pauseFor, _finishCallFunc);
  }

  void _finishCallFunc(int type, UTE.BaseTween source) {
    // Option #1
    inScene.visible = true;

    // Option #2
    // Restore back into view (aka the previous position).
    //inScene.setPosition(prevPos.x, prevPos.y);
    
    // Indicate the transition is complete/finished.
    finish(null);
  }
}