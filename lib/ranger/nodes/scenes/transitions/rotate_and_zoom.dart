part of ranger;

/**
 * An example [TransitionScene]. You are encouraged to be creative and
 * create your own.
 * Incoming scene scales from center while rotating. The effect is similar
 * to the classic newspaper flying into view.
 */
class TransitionRotateAndZoom extends TransitionScene {
  
  TransitionRotateAndZoom();
  
  factory TransitionRotateAndZoom.initWithDurationAndScene(double duration, Scene scene) {
    TransitionRotateAndZoom tScene = new TransitionRotateAndZoom();
    tScene.initWithDuration(duration, scene);
    return tScene;
  }
  
  void addedAsChild() {
    
  }

  @override
  void onEnter() {
    super.onEnter();

    Application app = Application.instance;

    AnchoredScene inComingScene = inScene as AnchoredScene;

    // Setup incoming scene first.
    // Set anchor to upper right
    inComingScene.setAnchorPositionByPercent(50.0, 50.0);
    inComingScene.anchor.rotationByDegrees = 0.0;
    inComingScene.anchor.uniformScale = 0.0;

    // Setup outgoing scene second.
    // Set anchor to lower left.
    
    UTE.Timeline par = new UTE.Timeline.parallel();
    
    par.push(app.animations.rotateBy(inScene, 
                                     duration / 1.5, 
                                     720.0, 
                                     UTE.Sine.OUT, null, false));

    par.push(app.animations.scaleTo(inScene, 
                                     duration / 1.2, 
                                     1.0, 1.0,
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