part of ranger;

class TransitionMoveInFrom extends TransitionScene {
  static const int FROM_RIGHT = 0;
  static const int FROM_LEFT = 1;
  static const int FROM_TOP = 2;
  static const int FROM_BOTTOM = 3;
  
  int _directionFrom = 0;
  
  TransitionMoveInFrom();
  
  /**
   * [duration] is in seconds
   * [scene] is the [Scene] to transition to.
   * [directionFrom] = FROM_RIGHT or FROM_LEFT or FROM_BOTTOM or FROM_TOP
   */
  factory TransitionMoveInFrom.initWithDurationAndScene(double duration, BaseNode scene, [int directionFrom = 0]) {
    TransitionMoveInFrom tScene = new TransitionMoveInFrom();
    tScene._directionFrom = directionFrom;
    tScene.initWithDuration(duration, scene);
    return tScene;
  }
  
  @override
  void onEnter() {
    super.onEnter();
    Application app = Application.instance;

    UTE.Timeline seq = new UTE.Timeline.sequence();
    AnchoredScene aScene = inScene as AnchoredScene;
    
    if (pauseFor > 0.0)
      seq.pushPause(pauseFor);
    
    // Note: If the Canvas is Left-handed then the top and bottom
    // animations will be flipped.
    switch (_directionFrom) {
      case FROM_LEFT:
        inScene.setPosition(-Application.instance.designSize.width, 0.0);

//        seq.push(UTE.Tween.to(aScene, AnchoredScene.TRANSLATE_X, duration)
//                ..targetValues = [0.0]
//                ..easing = UTE.Sine.INOUT);

        seq.push(app.animations.moveTo(inScene, duration, 0.0, 0.0, UTE.Sine.INOUT, AnchoredScene.TRANSLATE_X, null, false));
        break;
      case FROM_RIGHT:
        inScene.setPosition(Application.instance.designSize.width, 0.0);
        seq.push(app.animations.moveTo(inScene, duration, 0.0, 0.0, UTE.Sine.INOUT, AnchoredScene.TRANSLATE_X, null, false));
        break;
      case FROM_TOP:
        inScene.setPosition(0.0, -Application.instance.designSize.height);
        seq.push(app.animations.moveTo(inScene, duration, 0.0, 0.0, UTE.Sine.INOUT, AnchoredScene.TRANSLATE_Y, null, false));
        break;
      case FROM_BOTTOM:
        inScene.setPosition(0.0, Application.instance.designSize.height);
        seq.push(app.animations.moveTo(inScene, duration, 0.0, 0.0, UTE.Sine.INOUT, AnchoredScene.TRANSLATE_Y, null, false));
        break;
    }
    
//    UTE.Tween funcTw = UTE.Tween.to(aScene, TweenAnimation.NONE, 0.0)
//      ..targetValues = []
//      ..easing = UTE.Linear.INOUT
//      ..callback = _finishCallFunc
//      ..callbackTriggers = UTE.TweenCallback.COMPLETE;

    seq..push(app.animations.callFunc(0.0, _finishCallFunc, null, false))
    ..start();
//    seq..push(funcTw)
//      ..start(app.animations.tweenMan);
  }

  void _finishCallFunc(int type, UTE.BaseTween source) {
    finish(null);
//    switch(type) {
//      case UTE.TweenCallback.COMPLETE:
//        finish(null);
//        break;
//      //default:
//      //  print('DEFAULT CALLBACK CAUGHT ; type = ' + type.toString());
//    }
  }
}