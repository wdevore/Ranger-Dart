part of unittests;

/**
 * This test shows how to properly dispose of [Node]s once they are no
 * longer relevant. In this example as each [TextNode]'s animation is
 * [UTE.TweenCallback.COMPLETE] we [removeChild] as it is no longer visible.  
 */
class KeyboardLayer extends Ranger.BackgroundLayer {
  CanvasGradient _gradient;

  Ranger.SpriteImage _home;
  Ranger.SpriteImage _keyboard;
  Ranger.TextNode _cNode;
  
  String startColor;
  String endColor;
  
  RectangleNode _widerBar;
  RectangleNode _narrowBar;
  Ranger.TextNode _title;
  
  int _keyTag = 200000;
  KeyboardLayer();
 
  factory KeyboardLayer.basic([bool centered = true, int width, int height]) {
    KeyboardLayer layer = new KeyboardLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = false;
    return layer;
  }

  @override
  bool init([int width, int height]) {
    super.init(width, height);

    // Create two vertical bars.
    _widerBar = new RectangleNode.basic();
    _narrowBar = new RectangleNode.basic();
    
    _home = new Ranger.SpriteImage.withElement(GameManager.instance.resources.home);

    _keyboard = new Ranger.SpriteImage.withElement(GameManager.instance.resources.keyboard);
    
    Ranger.Application app = Ranger.Application.instance;
    // Because the TextNode isn't a Tweenable we need to register the 
    // class with the Tween system in order to recognize and animate it.
    UTE.Tween.registerAccessor(Ranger.TextNode, app.animations);

    _configure();
    
    return true;
  }
  
  @override
  void onEnter() {
    enableMouse = true;
    enableKeyboard = true;
    
    Ranger.Application app = Ranger.Application.instance;
    app.animations.alternateHandler = textCallbackHandler;

    super.onEnter();
  }
  
  @override
  void onExit() {
    super.onExit();
    
    // Just for this Layer we redirect the TweenAnimation's handler to
    // this node such that we can remove Text nodes as they complete their
    // animations.
    Ranger.Application app = Ranger.Application.instance;
    app.animations.resetToDefaultHandler();
    
    // Stop any previous animation so relative motion doesn't add up causing
    // the target to animate offscreen.
    app.animations.tweenMan.killTarget(_title, Ranger.TweenAnimation.TRANSLATE_Y);
    app.animations.tweenMan.killTarget(_cNode, Ranger.TweenAnimation.TRANSLATE_Y);
    app.animations.tweenMan.killTarget(_cNode, Ranger.TweenAnimation.TRANSLATE_X);
    app.animations.tweenMan.killTarget(_cNode, Ranger.TweenAnimation.ROTATE);
    app.animations.tweenMan.killTarget(_keyboard, Ranger.TweenAnimation.SHAKE);
    
  }

  @override
  bool onKeyPress(KeyboardEvent event) {
    _animateCharacter(new String.fromCharCode(event.charCode));
    _animateKeyboard();
    return true;
  }

  void textCallbackHandler(int type, UTE.BaseTween source) {
    switch(type) {
      case UTE.TweenCallback.COMPLETE:
        if (source.userData != null) {
          if (source.userData is int) {
            int tag = source.userData as int;
             Ranger.TextNode node = getChildByTag(tag);
            if (node != null) {
              removeChild(node, true);
            }
          }
        }
        break;
    }
  }
  
  void _animateCharacter(String char) {
    Ranger.Application app = Ranger.Application.instance;
    
    _cNode = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _cNode.text = char;
    _cNode.setPosition(0.0, -75.0);
    _cNode.uniformScale = 10.0;
    addChild(_cNode, 10, _keyTag);

    UTE.Timeline seq = new UTE.Timeline.sequence();

    // Optional Fade in. Would need to Create a Text node that mixes in
    // Color4Mixin to control transparency.
    
    // move down
    UTE.BaseTween moveDown = app.animations.moveBy(
        _cNode, 0.25,
        -150.0, 0.0,
        UTE.Cubic.OUT,
        Ranger.TweenAnimation.TRANSLATE_Y, null, false);
    seq.push(moveDown);
    // turn cw 90
    UTE.BaseTween cw1_90 = app.animations.rotateBy(
        _cNode, 0.5,
        -90.0,
        UTE.Linear.INOUT,
        null, false);
    seq.push(cw1_90);
    // move left
    UTE.BaseTween moveLeft = app.animations.moveBy(
        _cNode, 1.0,
        -330.0, 0.0,
        UTE.Cubic.OUT,
        Ranger.TweenAnimation.TRANSLATE_X, null, false);
    seq.push(moveLeft);
    // turn cw 90
    UTE.BaseTween cw2_90 = app.animations.rotateBy(
        _cNode, 0.5,
        -90.0,
        UTE.Linear.INOUT,
        null, false);
    seq.push(cw2_90);
    // move up
    UTE.BaseTween moveUp = app.animations.moveBy(
        _cNode, 0.75,
        300.0, 0.0,
        UTE.Cubic.OUT,
        Ranger.TweenAnimation.TRANSLATE_Y, null, false);
    seq.push(moveUp);
    // turn cw 90
    UTE.BaseTween cw3_90 = app.animations.rotateBy(
        _cNode, 0.5,
        -180.0,
        UTE.Linear.INOUT,
        null, false);
    seq.push(cw3_90);
    // move right off screen
    UTE.BaseTween moveRight = app.animations.moveBy(
        _cNode, 0.5,
        1200.0, 0.0,
        UTE.Cubic.IN,
        Ranger.TweenAnimation.TRANSLATE_X, _keyTag, false);
    
    seq.push(moveRight);
    
    _keyTag++;

    seq.start();
  }
  
  void _animateKeyboard() {
    // I am using an Immediately invoked Anonymous Closure 
    // to localize a variable rather creating a global variable.
    // In this case it is the initial position of the node being shaken.
    // originalPos could have been declared at the GameLayer level but
    // I didn't want the GameLayer littered with temporary objects just
    // for an animation.
    () {
      Ranger.Application app = Ranger.Application.instance;
      Ranger.Vector2P originalPos = new Ranger.Vector2P();
      UTE.Tween shake = app.animations.shake(
          _keyboard,
          0.25,
          2.0,
          (int type, UTE.BaseTween source) {
            switch(type) {
              case UTE.TweenCallback.BEGIN:
                Ranger.Node n = source.userData as Ranger.Node;
                originalPos.v.setFrom(n.position);
                break;
              case UTE.TweenCallback.END:
                Ranger.Node n = source.userData as Ranger.Node;
                n.position.setFrom(originalPos.v);
                originalPos.moveToPool();
                break;
            }
          }
      );
    }();
  }
  
  @override
  bool onMouseDown(MouseEvent event) {
    Ranger.Application app = Ranger.Application.instance;
    Ranger.Vector2P nodeP = app.drawContext.mapViewToNode(_home, event.offset.x, event.offset.y);
    nodeP.moveToPool();

    if (_home.containsPoint(nodeP.v)) {
      app.sceneManager.popScene();
    }
    return true;
  }
  
  void _configure() {
    Ranger.Application app = Ranger.Application.instance;
    
    double hHeight = app.designSize.height / 2.0;
    double hWidth = app.designSize.width / 2.0;
    double hGap = hWidth - (hWidth * 0.25);
    double vGap = hHeight - (hHeight * 0.25);
    
    addChild(_keyboard, 10, 3399);
    _keyboard.uniformScale = 5.0;
    _keyboard.setPosition(hGap, -vGap);
    
    addChild(_widerBar, 10, 125);
    _widerBar.fillColor = Ranger.color4IFromHex("#948794").toString();
    _widerBar.scaleTo(70.0, app.designSize.height);
    _widerBar.setPosition(-hGap + (hGap * 0.25), 0.0);
    _widerBar.center();

    addChild(_narrowBar, 10, 126);
    _narrowBar.fillColor = Ranger.color4IFromHex("#66435a").toString();
    _narrowBar.scaleTo(25.0, app.designSize.width);
    _narrowBar.setPosition(-hWidth, 100.0);
    _narrowBar.rotationByDegrees = -90.0;
    
    addChild(_home, 10, 120);
    _home.uniformScale = 5.0;
    _home.setPosition(hGap, vGap);

    //---------------------------------------------------------------
    // Create text nodes.
    //---------------------------------------------------------------
    double vDelta = -vGap * 2.0;
    _title = new Ranger.TextNode.initWith(Ranger.color4IFromHex("#425563"));
    _title.text = "Begin typing keys...";
    _title.setPosition(-hGap + (hGap * 0.35), vDelta);
    _title.strokeColor = Ranger.Color4IWhite;
    _title.strokeWidth = 1.0;
    _title.uniformScale = 10.0;
    addChild(_title, 10, 222);
    
    //---------------------------------------------------------------
    // Begin animating text into view.
    //---------------------------------------------------------------
    UTE.Timeline seq = new UTE.Timeline.sequence();
    
    UTE.Tween mTw1 = app.animations.moveBy(
        _title, 
        2.5,
        vDelta.abs(), 0.0,
        UTE.Cubic.OUT, Ranger.TweenAnimation.TRANSLATE_Y, null, false);
    
    seq..push(mTw1)
      ..start();

  }
 
  void drawBackground(Ranger.DrawContext context) {
    if (!transparentBackground) {
      CanvasRenderingContext2D context2D = context.renderContext as CanvasRenderingContext2D;

      Ranger.Size<double> size = contentSize;
      context.save();

      if (_gradient == null) {
        _gradient = context2D.createLinearGradient(0.0, 0.0, size.width, 0.0);
        _gradient.addColorStop(0.0, startColor);
        _gradient.addColorStop(1.0, endColor);
      }

      context2D..fillStyle = _gradient
          ..fillRect(0.0, 0.0, size.width, size.height);
      
      Ranger.Application.instance.objectsDrawn++;
      
      context.restore();
    }
  }

}
