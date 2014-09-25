part of ranger;

class _Tween {
  int tweenType;
  BaseNode node;
  _Tween(this.tweenType, this.node);
}

/**
 * [TweenAnimation] is a convenience class designed to help you apply
 * simple fire-and-forget animations. Over time you will most likely
 * begin creating your own Tweens directly and simply use the tweenMan
 * object. On the other you may find that it meets most of your needs.
 * 
 * [TweenAnimation] is automatically added as a "system" to the
 * [Scheduler] by the [Application._buildSystems] method.
 * 
 * TODO Add named parameters instead of optional.
 */
class TweenAnimation extends TimingTarget implements UTE.TweenAccessor<Node> {
  static const int TRANSLATE_X = 1;
  static const int TRANSLATE_Y = 2;
  static const int TRANSLATE_XY = 3;
  static const int SCALE_X = 10;
  static const int SCALE_Y = 11;
  static const int SCALE_XY = 12;
  static const int ROTATE = 50;
  
  static const int COLOR = 75;
  static const int TINT = 76;

  static const int FADE = 80;
  static const int VISIBLE = 81;
  static const int SHOW = 82;
  static const int HIDE = 83;
  
  static const int BLINK = 300;

  static const int ADDITION = 1000;
  static const int MULTIPLY = 1001;

  static const int NONE = 2001;

  // ---------------------------------------------------
  // Shake controls
  // ---------------------------------------------------
  static const int SHAKE = 200;
  Vector2 _displacment = new Vector2.zero();
  Vector2 _direction = new Vector2.zero();
  math.Random _randGen = new math.Random();
  double _displacementScale = 5.0;
  
  Vector2 _originalPos = new Vector2.zero();
  
  List<_Tween> _tweens = new List<_Tween>();
  
  /**
   * Some animations (for example [shake]) disturb the position without
   * restoring to a known position. This will cause a known position
   * after the [shake].
   * Default = true
   */
  bool resetToOriginalPosition = true;
  
  /**
   * This [TweenManager] is hooked up to the [Scheduler] as a [TimingTarget]
   * by the [Application._buildSystems]. 
   */
  UTE.TweenManager tweenMan = new UTE.TweenManager();
  
  /**
   * Be VERY careful overriding [TweenAnimation] handler. If you don't
   * manage your code correctly you could create some really strange
   * and difficult to find bugs.
   * Just remember to call [resetToDefaultHandler] when you are done, but
   * even that may not be enough. You could confuse other animations
   * that are in progress. So again use with caution.
   */
  UTE.TweenCallbackHandler alternateHandler;
  
  TweenAnimation() {
    resetToDefaultHandler();
    // Most animations in Ranger are no bigger than 4 components.
    // Example, color which is r,g,b,a = 4.
    UTE.Tween.combinedAttributesLimit = 4;
  }
  
  // TimingTarget implementation.
  void update(double dt) {
    tweenMan.update(dt);
  }
  
  void resetToDefaultHandler() {
    alternateHandler = tweenCallbackHandler;
  }
  
  /**
   * A default handler. It is used mostly for generic animation debugging.
   */
  void tweenCallbackHandler(int type, UTE.BaseTween source) {
    //print("TweenAnimation.tweenCallbackHandler $type");
//    BaseNode bn;
//    if (source.userData != null) {
//      if (source.userData is BaseNode) {
//        bn = source.userData as BaseNode;
//        if (bn.parent != null)
//          print("TweenAnimation.tweenCallbackHandler node: ${bn.tag}, parent:${bn.parent.tag}");
//        else
//          print("TweenAnimation.tweenCallbackHandler node: ${bn.tag}");
//      }
//    }
    
//    switch(type) {
//      case UTE.TweenCallback.BEGIN:
//        print("TweenAnimation.tweenCallbackHandler BEGIN");
//        break;
//      case UTE.TweenCallback.START:
//        print("TweenAnimation.tweenCallbackHandler START");
//        break;
//      case UTE.TweenCallback.END:
//        print("TweenAnimation.tweenCallbackHandler END");
//        break;
//      case UTE.TweenCallback.COMPLETE:
//        print("TweenAnimation.tweenCallbackHandler COMPLETE");
//        break;
//      default:
//        print('TweenAnimation.tweenCallbackHandler DEFAULT CALLBACK CAUGHT type:$type');
//    }
  }
  
  // Called for: UTE.build() and UTE...update()
  int getValues(Node target, UTE.Tween tween, int tweenType, List<num> returnValues) {
    //print("TweenAnimation.getValues: ${target}, tweenType:$tweenType, values: ${returnValues}");
    switch (tweenType) {
      case TRANSLATE_X:
        returnValues[0] = target.position.x;
        return 1;
      case TRANSLATE_Y:
        returnValues[0] = target.position.y;
        return 1;
      case SCALE_X:
        returnValues[0] = target.scale.x;
        return 1;
      case SCALE_Y:
        returnValues[0] = target.scale.y;
        return 1;
      case SCALE_XY:
        returnValues[0] = target.uniformScale;//target.scale.x;
        returnValues[1] = target.uniformScale;//target.scale.y;
        return 2;
      case TRANSLATE_XY:
      case SHAKE:
        returnValues[0] = target.position.x;
        returnValues[1] = target.position.y;
        return 2;
      case ROTATE:
        returnValues[0] = target.rotationInDegrees;
        return 1;
      case COLOR:
        if (target is Color4Mixin) {
          Color4Mixin cb = target as Color4Mixin;
          returnValues[0] = cb.color.r;
          returnValues[1] = cb.color.g;
          returnValues[2] = cb.color.b;
          returnValues[3] = cb.color.a;
        }
        return 4;
      case TINT:
        if (target is Color4Mixin) {
          Color4Mixin cb = target as Color4Mixin;
          returnValues[0] = cb.color.r;
          returnValues[1] = cb.color.g;
          returnValues[2] = cb.color.b;
        }
        return 3;
      case FADE:
        if (target is Color4Mixin) {
          Color4Mixin cb = target as Color4Mixin;
          returnValues[0] = cb.opacity;
        }
        return 1;
      case VISIBLE:
        target.visible = target.isVisible();
        return 0;
      default: return 0;
    }
  }
  
  void setValues(Node target, UTE.Tween tween, int tweenType, List<num> newValues) {
    //print("TweenAnimation.setValues: ${target}, tweenType:$tweenType, values: ${newValues}");
    switch (tweenType) {
      case TRANSLATE_X:
        target.position.x = newValues[0];
        target.dirty = true;
        break;
      case TRANSLATE_Y:
        target.position.y = newValues[0];
        target.dirty = true;
        break;
      case TRANSLATE_XY:
        target.position.x = newValues[0];
        target.position.y = newValues[1];
        target.dirty = true;
        break;
      case SCALE_X:
        target.scale.x = newValues[0];
        target.dirty = true;
        break;
      case SCALE_Y:
        target.scale.y = newValues[0];
        target.dirty = true;
        break;
      case SCALE_XY:
        target.uniformScale = newValues[0];
        break;
      case ROTATE:
        target.rotationByDegrees = newValues[0];
        target.dirty = true;
        break;
      case SHAKE:
        target.position.sub(_displacment);
        double angle = degreesToRadians(359.0 * _randGen.nextDouble());
        _direction.setValues(math.cos(angle), math.sin(angle));
        _displacment.setValues(_direction.x * _displacementScale, _direction.y * _displacementScale);
        target.position.add(_displacment);
        target.dirty = true;
        break;
      case COLOR:
        if (target is Color4Mixin) {
          Color4Mixin cb = target as Color4Mixin;
          cb.color.r = newValues[0].ceil();
          cb.color.g = newValues[1].ceil();
          cb.color.b = newValues[2].ceil();
          cb.color.a = newValues[3].ceil();
        }
        break;
      case TINT:
        if (target is Color4Mixin) {
          Color4Mixin cb = target as Color4Mixin;
          cb.color.r = newValues[0].ceil();
          cb.color.g = newValues[1].ceil();
          cb.color.b = newValues[2].ceil();
        }
        break;
      case FADE:
        if (target is Color4Mixin) {
          Color4Mixin cb = target as Color4Mixin;
          cb.opacity = newValues[0].ceil();
        }
        break;
      case VISIBLE:
        target.visible = !target.isVisible();
        break;
      case HIDE:
        target.visible = false;
        break;
      case SHOW:
        target.visible = true;
        break;
    }
  }

  double degreesToRadians(double degrees) {
    return degrees * math.PI / 180.0;
  }

  /**
   * Add an animation to this [TweenAccessor]'s [TweenManager].
   * [autoStart] is only applied if a value is provided. The default
   * is to auto start.
   */
  void add(UTE.BaseTween tween, [bool autoStart]) {
    if (autoStart != null)
      UTE.TweenManager.setAutoStart(tween, autoStart);
    tweenMan.add(tween);
  }
  
  /**
   * Typically you would add [BaseNode]s that you don't want to remember
   * when it is time to "kill"/Terminate them. Most likely this is
   * [Tween.INFINITY] type animations.
   */
  void track(BaseNode node, int tweenType) {
    _tweens.add(new _Tween(tweenType, node));
  }
  
  /**
   * Terminates any animations attached to [BaseNode]s.
   * Most likely they are [Tween.INFINITY] type animations. 
   */
  void flushAll() {
//    for(_Tween t in _tweens) {
//      print("TweenAnimation.flushAll killing ${t.node.tag}, type:${t.tweenType}");
//      stop(t.node, t.tweenType);
//    }
    _tweens.forEach((_Tween t) => stop(t.node, t.tweenType));
    _tweens.clear();
  }
  
  /**
   * Terminates an animation attached to a [BaseNode].
   * Most likely it is a [Tween.INFINITY] type animation.
   * Note: infinite animations continue even if the node is gone, which is
   * wasted cycles. This is why it is important you "flush" infinite
   * animations when you don't want/need them anymore. 
   */
  void flush(BaseNode node) {
    _Tween tw = _tweens.firstWhere((_Tween t) => t.node == node, orElse: () => null);
    if (tw != null) {
      //print("TweenAnimation.flush killing ${tw.node.tag}, type:${tw.tweenType}");
      stop(tw.node, tw.tweenType);
      _tweens.remove(tw);
    }
  }
  
  void stop(BaseNode node, int tweenType) {
    tweenMan.killTarget(node, tweenType);
  }
  
  // ---------------------------------------------------------------
  // Visibility
  // ---------------------------------------------------------------
  UTE.BaseTween fadeTo(
              Node node, 
              double duration, 
              num alpha, 
              UTE.TweenEquation easeEquation,
              [Object userData,
               bool autoStart = true]) {
    UTE.Tween tw = new UTE.Tween.to(node, TweenAnimation.FADE, duration)
      ..targetValues = [alpha]
      ..easing = easeEquation
      ..callback = alternateHandler
      ..callbackTriggers = UTE.TweenCallback.ANY;
      
    if (userData != null)
      tw.userData = userData;
    else
      tw.userData = node;
      
    add(tw, autoStart);
    
    return tw;
  }
  
  UTE.BaseTween fadeIn(Node node, 
              double duration, 
              UTE.TweenEquation easeEquation,
              [Object userData,
               bool autoStart = true]) {
    UTE.Tween tw = new UTE.Tween.to(node, TweenAnimation.FADE, duration)
      ..targetValues = [255.0]
      ..easing = easeEquation
      ..callback = alternateHandler
      ..callbackTriggers = UTE.TweenCallback.ANY;

    if (userData != null)
      tw.userData = userData;
    else
      tw.userData = node;
      
    UTE.TweenManager.setAutoStart(tw, autoStart);
    tweenMan.add(tw);
    
    return tw;
  }
  
  UTE.BaseTween fadeOut(
              Node node, 
              double duration, 
              UTE.TweenEquation easeEquation,
              [Object userData,
               bool autoStart = true]) {
    UTE.Tween tw = new UTE.Tween.to(node, TweenAnimation.FADE, duration)
      ..targetValues = [0.0]
      ..easing = easeEquation
      ..callback = alternateHandler
      ..callbackTriggers = UTE.TweenCallback.ANY;

    if (userData != null)
      tw.userData = userData;
    else
      tw.userData = node;
      
    UTE.TweenManager.setAutoStart(tw, autoStart);
    tweenMan.add(tw);
    
    return tw;
  }
  
  UTE.BaseTween toggleVisible(Node node, 
              [Object userData,
               bool autoStart = true]) {
    UTE.Tween tw = new UTE.Tween.to(node, TweenAnimation.VISIBLE, 0.0);

    if (userData != null)
      tw.userData = userData;
    else
      tw.userData = node;

    UTE.TweenManager.setAutoStart(tw, autoStart);
    tweenMan.add(tw);
    
    return tw;
  }
  
  UTE.BaseTween hide(Node node, 
              [Object userData,
               bool autoStart = true]) {
    UTE.Tween tw = new UTE.Tween.to(node, TweenAnimation.HIDE, 0.0);
    if (userData != null)
      tw.userData = userData;
    else
      tw.userData = node;
      
    UTE.TweenManager.setAutoStart(tw, autoStart);
    tweenMan.add(tw);
    
    return tw;
  }
  
  UTE.BaseTween show(Node node, 
              [Object userData, 
               bool autoStart = true]) {
    UTE.Tween tw = new UTE.Tween.to(node, TweenAnimation.SHOW, 0.0);
    if (userData != null)
      tw.userData = userData;
    else
      tw.userData = node;
      
    UTE.TweenManager.setAutoStart(tw, autoStart);
    tweenMan.add(tw);
    
    return tw;
  }
  
  UTE.BaseTween blink(Node node,
                        double onDuration, double offDuration,
                        [int repeatCount = UTE.Tween.INFINITY,
                        bool autoStart = true]) {
    UTE.Timeline tw = new UTE.Timeline.sequence()
        ..callback = alternateHandler
        ..callbackTriggers = UTE.TweenCallback.ANY;

    tw.userData = node;

    tw..push(new UTE.Tween.to(node, TweenAnimation.SHOW, 0.0))
      ..pushPause(onDuration)
      ..push(new UTE.Tween.to(node, TweenAnimation.HIDE, 0.0))
      ..pushPause(offDuration)
      ..repeat(repeatCount, 0);
      
    UTE.TweenManager.setAutoStart(tw, autoStart);
    tweenMan.add(tw);
    
    return tw;
  }
  
  // ---------------------------------------------------------------
  // Color
  // ---------------------------------------------------------------
  UTE.BaseTween colorTo(Node node, 
              double duration, 
              num r, num g, num b, num a, 
              UTE.TweenEquation easeEquation,
              [Object userData, 
               bool autoStart = true]) {

    UTE.Tween tw = new UTE.Tween.to(node, TweenAnimation.COLOR, duration)
      ..targetValues = [r, g, b, a]
      ..easing = easeEquation
      ..callback = alternateHandler
      ..callbackTriggers = UTE.TweenCallback.ANY;

    if (userData != null)
      tw.userData = userData;
    else
      tw.userData = node;

    UTE.TweenManager.setAutoStart(tw, autoStart);
    tweenMan.add(tw);
    
    return tw;
  }

  UTE.BaseTween tintTo(Node node, 
              double duration, 
              num r, num g, num b, 
              UTE.TweenEquation easeEquation,
              [Object userData,
               bool autoStart = true]) {
    UTE.Tween tw = new UTE.Tween.to(node, TweenAnimation.TINT, duration)
      ..targetValues = [r, g, b]
      ..easing = easeEquation
      ..callback = alternateHandler
      ..callbackTriggers = UTE.TweenCallback.ANY;

    if (userData != null)
      tw.userData = userData;
    else
      tw.userData = node;
      
    UTE.TweenManager.setAutoStart(tw, autoStart);
    tweenMan.add(tw);
    
    return tw;
  }

  // ---------------------------------------------------------------
  // Rotations
  // ---------------------------------------------------------------
  /**
   * Rotate [node] to an absolute angle over a period specified by
   * [duration].
   * [toDegree] destination angle in Degrees.
   * [userData] is an abitrary object you specify.
   * [autoStart] defaults to true.
   */
  UTE.BaseTween rotateTo(Node node, 
              double duration, 
              double toDegree, 
              UTE.TweenEquation easeEquation,
              [Object userData,
               bool autoStart = true]) {
    UTE.Tween tw = new UTE.Tween.to(node, TweenAnimation.ROTATE, duration)
      ..targetValues = [toDegree]
      ..easing = easeEquation
      ..callback = alternateHandler
      ..callbackTriggers = UTE.TweenCallback.ANY;

    if (userData != null)
      tw.userData = userData;
    else
      tw.userData = node;
      
    UTE.TweenManager.setAutoStart(tw, autoStart);
    tweenMan.add(tw);
    
    return tw;
  }

  UTE.BaseTween rotateBy(
              Node node, 
              double duration, 
              double deltaDegrees,
              UTE.TweenEquation easeEquation,
              [Object userData, 
               bool autoStart = true]) {
    UTE.Tween tw = new UTE.Tween.to(node, TweenAnimation.ROTATE, duration)
      ..targetRelative = [deltaDegrees]
      ..easing = easeEquation
      ..callback = alternateHandler
      ..callbackTriggers = UTE.TweenCallback.ANY;

    if (userData != null)
      tw.userData = userData;
    else
      tw.userData = node;
      
    UTE.TweenManager.setAutoStart(tw, autoStart);
    tweenMan.add(tw);
    
    return tw;
  }

  // ---------------------------------------------------------------
  // Scales
  // ---------------------------------------------------------------
  UTE.BaseTween scaleTo(Node node, 
              double duration, 
              double toX, double toY, 
              UTE.TweenEquation easeEquation,
              [int tweenType = TweenAnimation.SCALE_XY, 
               Object userData,
               int scaleEffect = ADDITION,
               bool autoStart = true]) {
    UTE.Tween tw = new UTE.Tween.to(node, tweenType, duration)
      ..easing = easeEquation
      ..callback = alternateHandler
      ..callbackTriggers = UTE.TweenCallback.ANY;

    if (userData != null)
      tw.userData = userData;
    else
      tw.userData = node;
      
    if (scaleEffect == MULTIPLY) {
      if (tweenType == SCALE_XY)
        tw.targetValues = [node.uniformScale * toX, node.uniformScale * toY];
      else
        tw.targetValues = [node.scale.x * toX, node.scale.y * toY];
    }
    else
      tw.targetValues = [toX, toY];

    UTE.TweenManager.setAutoStart(tw, autoStart);
    tweenMan.add(tw);
    
    return tw;
  }
  
  /**
   * [scaleEffect] defaults to [MULTIPLY] which is the original behaviour
   * of Cocos2D where by the target scale is determined by scaling the current
   * scale by the delta given.
   * Using [ADDITION] is the basic behavious of the Universal
   * Tween Engine approach which is to scale by successive addition
   * relative to the current scale value.
   */
  UTE.BaseTween scaleBy(Node node, 
              double duration, 
              double dx, double dy,
              UTE.TweenEquation easeEquation,
              [int tweenType = TweenAnimation.SCALE_XY, 
               Object userData,
               int scaleEffect = MULTIPLY,
               bool autoStart = true]) {
    UTE.Tween tw = new UTE.Tween.to(node, tweenType, duration)
      ..easing = easeEquation
      ..callback = alternateHandler
      ..callbackTriggers = UTE.TweenCallback.ANY;

    if (userData != null)
      tw.userData = userData;
    else
      tw.userData = node;

    if (scaleEffect == MULTIPLY)
      tw.targetRelative = [node.scale.x * dx, node.scale.y * dy];
    else
      tw.targetRelative = [dx, dy];

    UTE.TweenManager.setAutoStart(tw, autoStart);
    tweenMan.add(tw);
    
    return tw;
  }

  // ---------------------------------------------------------------
  // Translations
  // ---------------------------------------------------------------
  /**
   * Animate [node] to an absolute position over a period specified by
   * [duration].
   * Depending on the [tweenType] either [toData1] or both [toData2] are
   * provided. For example, if [tweenType] is [TweenAnimation.TRANSLATE_XY]
   * then both [toData1] and needed [toData2] where [toData1] is the X
   * position and [toData2] is the Y position.
   * [userData] is an abitrary object you specify.
   * [autoStart] defaults to true.
   */
  UTE.BaseTween moveTo(Node node,
              double duration, 
              double toData1, double toData2, 
              UTE.TweenEquation easeEquation,
              [int tweenType = TweenAnimation.TRANSLATE_XY, 
               Object userData,
               bool autoStart = true]) {
    UTE.Tween tw = new UTE.Tween.to(node, tweenType, duration)
      ..targetValues = [toData1, toData2]
      ..easing = easeEquation
      ..callback = alternateHandler
      ..callbackTriggers = UTE.TweenCallback.ANY;

    if (userData != null)
      tw.userData = userData;
    else
      tw.userData = node;
      
    UTE.TweenManager.setAutoStart(tw, autoStart);
    tweenMan.add(tw);
    
    return tw;
  }
  
  UTE.BaseTween moveBy(Node node, 
              double duration, 
              double dx, double dy,
              UTE.TweenEquation easeEquation,
              [int tweenType = TweenAnimation.TRANSLATE_XY, 
               Object userData, 
               bool autoStart = true]) {
    UTE.Tween tw = new UTE.Tween.to(node, tweenType, duration)
      ..targetRelative = [dx, dy]
      ..easing = easeEquation
      ..callback = alternateHandler
      ..callbackTriggers = UTE.TweenCallback.ANY;

    if (userData != null)
      tw.userData = userData;
    else
      tw.userData = node;
      
    UTE.TweenManager.setAutoStart(tw, autoStart);
    tweenMan.add(tw);
    
    return tw;
  }
  
  // ---------------------------------------------------------------
  // Misc
  // ---------------------------------------------------------------
  UTE.BaseTween callFunc( 
              double delay,
              UTE.TweenCallbackHandler callback,
              [Object userData,
               bool autoStart = true]) {

    UTE.Tween tw = new UTE.Tween.call(callback)
      ..delay = delay
      ..userData = userData;
      
    UTE.TweenManager.setAutoStart(tw, autoStart);
    tweenMan.add(tw);
    
    return tw;
  }
  
  /**
   * If you don't supply a [handler] then the object being shaken will
   * not reset back to its original position; it will "drift".
   * 
   * A suggested way of using [shake] is to use an Anonymous Closure to
   * localize a variable rather creating a global variable
   * Here is an exmaple of a Layer wanting to shake a node:
   * 
   *     () {
   *        Ranger.Application app = Ranger.Application.instance;
   *        Ranger.Vector2P originalPos = new Ranger.Vector2P();
   *        UTE.Tween shake = app.animations.shake(
   *            _pointColorNode,
   *            0.25,
   *            5.0,
   *            (int type, UTE.BaseTween source) {
   *              switch(type) {
   *                case UTE.TweenCallback.BEGIN:
   *                  Ranger.Node n = source.userData as Ranger.Node;
   *                  originalPos.v.setFrom(n.position);
   *                  break;
   *                case UTE.TweenCallback.END:
   *                  Ranger.Node n = source.userData as Ranger.Node;
   *                  n.position.setFrom(originalPos.v);
   *                  originalPos.moveToPool();
   *                  break;
   *              }
   *            }
   *        );
   *     }();
   * In this case it is the position of the node being shaken.
   * originalPos could have been declared at the GameLayer level but
   * I didn't want the GameLayer littered with temporary objects just
   * for an animation.
   * There is one downside, if another shake is compounded before previous
   * shakes complete then subsequent shakes will pickup the current shaked
   * position, something you may not want.
   * Ultimately, you end up having to use a global variable.
   */
  UTE.BaseTween shake(
              Node node, 
              double duration,
              double displacmentScale,
              [UTE.TweenCallbackHandler handler,
              bool autoStart = true]) {
    
    _displacementScale = displacmentScale;
    
    // easing and targetValues are just place holders; they are
    // meaningless for Shakes.
    UTE.Tween tw = new UTE.Tween.to(node, TweenAnimation.SHAKE, duration)
      ..targetValues = [0.0, 0.0]
      ..easing = UTE.Linear.INOUT
      ..callback = handler
      ..callbackTriggers = UTE.TweenCallback.ANY
      ..userData = node;
      
    UTE.TweenManager.setAutoStart(tw, autoStart);
    tweenMan.add(tw);
    
    return tw;
  }
  
//  void _shakeTweenCallback(int type, UTE.BaseTween source) {
//    switch(type) {
//      case UTE.TweenCallback.BEGIN:
//        Node n = source.userData as Node;
//        _originalPos.setFrom(n.position);
//        break;
//      case UTE.TweenCallback.END:
//        Node n = source.userData as Node;
//          if (resetToOriginalPosition) {
//            n.position.setFrom(_originalPos);
//          }
//        break;
//    }
//  }
}
