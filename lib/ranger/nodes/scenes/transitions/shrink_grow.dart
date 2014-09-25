part of ranger;

/**
 * An example [TransitionScene]. You are encouraged to be creative and
 * create your own.
 * This transition shrinks the outgoing scene into the lower-left
 * corner while expanding the incoming scene from the upper-right
 */
class TransitionShrinkGrow extends TransitionScene {
  TransitionShrinkGrow();
  
  /**
   * [duration] is in seconds
   * [scene] is the [Scene] to transition to.
   */
  factory TransitionShrinkGrow.initWithDurationAndScene(double duration, BaseNode scene) {
    TransitionShrinkGrow tScene = new TransitionShrinkGrow();
    tScene.initWithDuration(duration, scene);
    return tScene;
  }
  
  @override
  void onEnter() {
    super.onEnter();

    // Note: if the Canvas is left-handed then the effect occurs in
    // the lower left corner.
    Application app = Application.instance;

    AnchoredScene inComingScene = inScene as AnchoredScene;
    AnchoredScene outGoingScene = outScene as AnchoredScene;
    
    // Setup outgoing scene first.
    // Set anchor to upper right
    outGoingScene.setAnchorPositionByPercent(100.0, 100.0);
    outGoingScene.anchor.uniformScale = 1.0;

    // Setup incoming scene second.
    // Set anchor to lower left.
    inComingScene.setAnchorPositionByPercent(0.0, 0.0);
    inComingScene.anchor.uniformScale = 0.0;

    UTE.Timeline par = new UTE.Timeline.parallel();
    
    par.push(app.animations.scaleTo(inScene, 
                                     duration, 
                                     1.0, 1.0,
                                     UTE.Sine.OUT, 
                                     TweenAnimation.SCALE_XY, 
                                     null, TweenAnimation.MULTIPLY, false));

    par.push(app.animations.scaleTo(outScene, 
                                     duration, 
                                     0.0, 0.0,
                                     UTE.Sine.OUT, 
                                     TweenAnimation.SCALE_XY, 
                                     null, TweenAnimation.MULTIPLY, false));

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