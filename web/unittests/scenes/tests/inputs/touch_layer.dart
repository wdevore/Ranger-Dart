part of unittests;

/**
 * NOT COMPLETE YET!
 */
class TouchLayer extends Ranger.BackgroundLayer {
  CanvasGradient _gradient;

  Ranger.SpriteImage _home;
  Ranger.SpriteImage _touch;
  Ranger.SpriteImage _skull;
  
  String startColor;
  String endColor;
  
  Ranger.TextNode _title;
  
  TouchLayer();
 
  factory TouchLayer.basic([bool centered = true, int width, int height]) {
    TouchLayer layer = new TouchLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = false;
    return layer;
  }

  @override
  bool init([int width, int height]) {
    super.init(width, height);

    _home = new Ranger.SpriteImage.withElement(GameManager.instance.resources.home);

    _touch = new Ranger.SpriteImage.withElement(GameManager.instance.resources.touch);
    _skull = new Ranger.SpriteImage.withElement(GameManager.instance.resources.skull);
    
    Ranger.Application app = Ranger.Application.instance;
    // Because the TextNode isn't a Tweenable we need to register the 
    // class with the Tween system in order to recognize and animate it.
    UTE.Tween.registerAccessor(Ranger.TextNode, app.animations);

    _configure();
    
    return true;
  }
  
  @override
  void onEnter() {
    enableTouch = true;
    enableMouse = true;
    
    super.onEnter();
  }
  
  @override
  void onExit() {
    super.onExit();
    
    Ranger.Application app = Ranger.Application.instance;
    // Stop any previous animation so relative motion doesn't add up causing
    // the target to animate offscreen.
    app.animations.tweenMan.killTarget(_title, Ranger.TweenAnimation.TRANSLATE_Y);
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
    
    addChild(_touch, 10, 3399);
    _touch.uniformScale = 5.0;
    _touch.setPosition(hGap, -vGap);
    
    addChild(_skull, 10, 125);
    _skull.scaleTo(20.0, 20.0);
    _skull.setPosition(0.0, 0.0);

    addChild(_home, 10, 120);
    _home.uniformScale = 5.0;
    _home.setPosition(hGap, vGap);

    //---------------------------------------------------------------
    // Create text nodes.
    //---------------------------------------------------------------
    double vDelta = -vGap * 2.0;
    _title = new Ranger.TextNode.initWith(Ranger.color4IFromHex("#425563"));
    _title.text = "Touch not complete...";
    _title.setPosition(-hWidth + (hGap * 0.15), vDelta);
    _title.strokeColor = Ranger.Color4IWhite;
    _title.strokeWidth = 1.0;
    _title.uniformScale = 7.0;
    addChild(_title, 10, 222);
    
    //---------------------------------------------------------------
    // Begin animating text into view.
    //---------------------------------------------------------------
    // Stop any previous animation so relative motion doesn't add up causing
    // the target to animate offscreen.
    app.animations.tweenMan.killTarget(_title, Ranger.TweenAnimation.TRANSLATE_Y);
    
    UTE.Timeline seq = new UTE.Timeline.sequence();
    
    UTE.Tween mTw1 = app.animations.moveBy(
        _title, 
        2.5,
        vDelta.abs() / 2.5, 0.0,
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
        _gradient = context2D.createLinearGradient(500.0, 0.0, 0.0, size.height);
        _gradient.addColorStop(0.0, startColor);
        _gradient.addColorStop(0.5, endColor);
      }

      context2D..fillStyle = _gradient
          ..fillRect(0.0, 0.0, size.width, size.height);
      
      Ranger.Application.instance.objectsDrawn++;
      
      context.restore();
    }
  }

}
