part of ranger;

class TransitionSlideIn extends TransitionScene {
  static const int FROM_RIGHT = 0;
  static const int FROM_LEFT = 1;
  static const int FROM_TOP = 2;
  static const int FROM_BOTTOM = 3;
  
  int _directionFrom = 0;
  
  TransitionSlideIn();
  
  /**
   * [duration] is in seconds
   * [scene] is the [Scene] to transition to.
   * [directionFrom] = FROM_RIGHT or FROM_LEFT or FROM_BOTTOM or FROM_TOP
   */
  factory TransitionSlideIn.initWithDurationAndScene(double duration, BaseNode scene, [int directionFrom = 0]) {
    TransitionSlideIn tScene = new TransitionSlideIn();
    tScene._directionFrom = directionFrom;
    tScene.initWithDuration(duration, scene);
    return tScene;
  }
  
  @override
  void onEnter() {
    super.onEnter();

    double width = Application.instance.designSize.width;
    double height = Application.instance.designSize.height;
    
    Application app = Application.instance;

    UTE.Timeline seq = new UTE.Timeline.sequence();

    if (pauseFor > 0.0)
      seq.pushPause(pauseFor);

    switch (_directionFrom) {
      case FROM_LEFT:
        inScene.setPosition(-width, 0.0);
        UTE.Timeline par = new UTE.Timeline.parallel();
        par.push(app.animations.moveBy(inScene, duration, width, 0.0, UTE.Sine.INOUT, TweenAnimation.TRANSLATE_X, null, false));
        par.push(app.animations.moveBy(outScene, duration, width, 0.0, UTE.Sine.INOUT, TweenAnimation.TRANSLATE_X, null, false));
        seq.push(par);
        break;
      case FROM_RIGHT:
        inScene.setPosition(width, 0.0);
        UTE.Timeline par = new UTE.Timeline.parallel();
        par.push(app.animations.moveBy(inScene, duration, -width, 0.0, UTE.Sine.INOUT, TweenAnimation.TRANSLATE_X, null, false));
        par.push(app.animations.moveBy(outScene, duration, -width, 0.0, UTE.Sine.INOUT, TweenAnimation.TRANSLATE_X, null, false));
        seq.push(par);
        break;
      case FROM_TOP:
        inScene.setPosition(0.0, height);
        UTE.Timeline par = new UTE.Timeline.parallel();
        // Note: the X and Y parameters are NOT positional based. For example,
        // This animation only effects the Y axis so only 1 of the parameters
        // is needed, the second isn't relevant. So the Y value is passed
        // first then an arbitrary value (in this case 0.0).
        // Your first intuition is to pass height second but that would
        // mean nothing would happen.
        par.push(app.animations.moveBy(inScene, duration, -height, 0.0, UTE.Sine.INOUT, TweenAnimation.TRANSLATE_Y, null, false));
        par.push(app.animations.moveBy(outScene, duration, -height, 0.0, UTE.Sine.INOUT, TweenAnimation.TRANSLATE_Y, null, false));
        seq.push(par);
        break;
      case FROM_BOTTOM:
        inScene.setPosition(0.0, -height);
        UTE.Timeline par = new UTE.Timeline.parallel();
        par.push(app.animations.moveBy(inScene, duration, height, 0.0, UTE.Sine.INOUT, TweenAnimation.TRANSLATE_Y, null, false));
        par.push(app.animations.moveBy(outScene, duration, height, 0.0, UTE.Sine.INOUT, TweenAnimation.TRANSLATE_Y, null, false));
        seq.push(par);
        break;
    }

    seq..push(app.animations.callFunc(0.0, _finishCallFunc, null, false))
       ..start();
  }

  void _finishCallFunc(int type, UTE.BaseTween source) {
    finish(null);
  }

}