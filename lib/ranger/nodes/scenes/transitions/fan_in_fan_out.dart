part of ranger;

/**
 * An example [TransitionScene]. You are encouraged to be creative and
 * create your own.
 * Incoming scene fans in from left. The rotation anchor is in the lower
 * left. The Outgoing scene fans out from the right. The rotation anchor
 * is in the upper right.
 */
class TransitionFanInFanOut extends TransitionScene {
  static const int FROM_RIGHT = 0;
  static const int FROM_LEFT = 1;
  static const int FROM_TOP = 2;
  static const int FROM_BOTTOM = 3;
  
  TransitionFanInFanOut();
  
  /**
   * [duration] is in seconds
   * [scene] is the [Scene] to transition to.
   */
  factory TransitionFanInFanOut.initWithDurationAndScene(double duration, BaseNode scene) {
    TransitionFanInFanOut tScene = new TransitionFanInFanOut();
    tScene.initWithDuration(duration, scene);
    return tScene;
  }
  
  @override
  void onEnter() {
    super.onEnter();
    Application app = Application.instance;

    AnchoredScene inComingScene = inScene as AnchoredScene;
    AnchoredScene outGoingScene = outScene as AnchoredScene;

    // Setup incoming scene first.
    // Set anchor to upper right
    inComingScene.setAnchorPositionByPercent(100.0, 100.0);
    inComingScene.anchor.rotationByDegrees = -90.0;
    
    // Setup outgoing scene second.
    // Set anchor to lower left.
    outGoingScene.setAnchorPositionByPercent(0.0, 0.0);
    
    UTE.Timeline par = new UTE.Timeline.parallel();
    
    par.push(app.animations.rotateBy(inScene, 
                                     duration * 1.5, 
                                     90.0, 
                                     UTE.Bounce.OUT, null, false));

    par.push(app.animations.rotateBy(outScene, 
                                     duration, 
                                     90.0, 
                                     UTE.Sine.IN, null, false));

    UTE.Timeline seq = new UTE.Timeline.sequence();
    if (pauseFor > 0.0)
      seq.pushPause(pauseFor);
    seq.push(par);
    seq..push(app.animations.callFunc(0.0, _finishCallFunc, null, false))
       ..start();
  }

  void _finishCallFunc(int type, UTE.BaseTween source) {
    finish(null);
  }

}