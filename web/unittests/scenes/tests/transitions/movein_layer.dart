part of unittests;

/**
 * Layer has 4 arrow buttons for transitioning in 4 directions.
 * 
 */
class MoveInLayer extends Ranger.BackgroundLayer {
  CanvasGradient _gradient;

  Ranger.SpriteImage _rightArrow;
  Ranger.SpriteImage _leftArrow;
  Ranger.SpriteImage _upArrow;
  Ranger.SpriteImage _downArrow;
  Ranger.SpriteImage _home;
  Ranger.TextNode _title;

  String startColor;
  String endColor;
  
  MoveInLayer();
 
  factory MoveInLayer.basic([bool centered = true, int width, int height]) {
    MoveInLayer layer = new MoveInLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = false;
    return layer;
  }

  @override
  bool init([int width, int height]) {
    super.init(width, height);

    // Arrow located on the right side of the view not the image appearance.
    _rightArrow = new Ranger.SpriteImage.withElement(GameManager.instance.resources.leftArrow);
    
    _leftArrow = new Ranger.SpriteImage.withElement(GameManager.instance.resources.leftArrow);
    _leftArrow.rotationByDegrees = 180.0;
   
    _upArrow = new Ranger.SpriteImage.withElement(GameManager.instance.resources.upArrow);
    _upArrow.rotationByDegrees = 180.0;
    
    _downArrow = new Ranger.SpriteImage.withElement(GameManager.instance.resources.upArrow);
    _home = new Ranger.SpriteImage.withElement(GameManager.instance.resources.home);

    _configure();
    
    return true;
  }
  
  @override
  void onEnter() {
    enableMouse = true;
    super.onEnter();

  }
  
  @override
  bool onMouseDown(MouseEvent event) {
    Ranger.Application app = Ranger.Application.instance;
    Ranger.Vector2P nodeP = app.drawContext.mapViewToNode(_rightArrow, event.offset.x, event.offset.y);
    nodeP.moveToPool();

    if (_rightArrow.containsPoint(nodeP.v)) {
      _transition(Ranger.TransitionMoveInFrom.FROM_RIGHT, Ranger.color4IFromHex("#0067a0"), Ranger.color4IFromHex("#b8dde1"));
      return true;
    }
    
    nodeP = app.drawContext.mapViewToNode(_leftArrow, event.offset.x, event.offset.y);
    nodeP.moveToPool();
    if (_leftArrow.containsPoint(nodeP.v)) {
      _transition(Ranger.TransitionMoveInFrom.FROM_LEFT, Ranger.color4IFromHex("#40c1ac"), Ranger.color4IFromHex("#18332f"));
      return true;
    }
    
    nodeP = app.drawContext.mapViewToNode(_upArrow, event.offset.x, event.offset.y);
    nodeP.moveToPool();
    if (_upArrow.containsPoint(nodeP.v)) {
      _transition(Ranger.TransitionMoveInFrom.FROM_BOTTOM, Ranger.color4IFromHex("#c5e86c"), Ranger.color4IFromHex("#555025"));
      return true;
    }

    nodeP = app.drawContext.mapViewToNode(_downArrow, event.offset.x, event.offset.y);
    nodeP.moveToPool();
    if (_downArrow.containsPoint(nodeP.v)) {
      _transition(Ranger.TransitionMoveInFrom.FROM_TOP, Ranger.color4IFromHex("#4f2c1d"), Ranger.color4IFromHex("#cda788"));
      return true;
    }
    
    nodeP = app.drawContext.mapViewToNode(_home, event.offset.x, event.offset.y);
    nodeP.moveToPool();
    if (_home.containsPoint(nodeP.v)) {
      app.sceneManager.popScene();
    }
    return true;
  }
  
  void _transition(int direction, Ranger.Color4<int> startColor, Ranger.Color4<int> endColor) {
    MoveInScene inComingScene = new MoveInScene();
    inComingScene.backgroundGradient(startColor, endColor);
    inComingScene.tag = 410;
    
    Ranger.TransitionScene transition = new Ranger.TransitionMoveInFrom.initWithDurationAndScene(0.5, inComingScene, direction);
    transition.tag = 9092;
    
    // This will replace the current Scene (aka MainMoveInScene invoked
    // from the GameLayer) with the new transition.
    // When the transition completes the new MainMoveInScene will at the
    // top of the stack.
    Ranger.Application app = Ranger.Application.instance;
    app.sceneManager.replaceScene(transition);
  }
  
  @override
  void onExit() {
    super.onExit();
    Ranger.Application app = Ranger.Application.instance;
    // Stop any previous animation so relative motion doesn't add up causing
    // the target to animate offscreen.
    app.animations.tweenMan.killTarget(_title, Ranger.TweenAnimation.TRANSLATE_Y);
  }

  void _configure() {
    Ranger.Application app = Ranger.Application.instance;
    
    double hHeight = app.designSize.height / 2.0;
    double hWidth = app.designSize.width / 2.0;
    double hGap = hWidth - (hWidth * 0.25);
    double vGap = hHeight - (hHeight * 0.25);
    
    addChild(_rightArrow, 10, 117);
    _rightArrow.uniformScale = 5.0;
    _rightArrow.setPosition(hGap, 0.0);

    addChild(_leftArrow, 10, 118);
    _leftArrow.uniformScale = 5.0;
    _leftArrow.setPosition(-hGap, 0.0);

    addChild(_upArrow, 10, 119);
    _upArrow.uniformScale = 5.0;
    _upArrow.setPosition(0.0, vGap);

    addChild(_downArrow, 10, 120);
    _downArrow.uniformScale = 5.0;
    _downArrow.setPosition(0.0, -vGap);

    addChild(_home, 10, 120);
    _home.uniformScale = 5.0;
    _home.setPosition(hGap, vGap);

    //---------------------------------------------------------------
    // Create text nodes.
    //---------------------------------------------------------------
    _title = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _title.text = "Move-In transitions";
    _title.setPosition(-hGap - 150.0, vGap - 90.0);
    _title.uniformScale = 5.0;
    addChild(_title, 10, 222);
    
    //---------------------------------------------------------------
    // Begin animating text into view.
    //---------------------------------------------------------------
    // Because the TextNode isn't a Tweenable we need to register the 
    // class with the Tween system in order to recognize and animate it.
    UTE.Tween.registerAccessor(Ranger.TextNode, app.animations);

    UTE.Timeline seq = new UTE.Timeline.sequence();
    
    double vertPos = hHeight - (app.designSize.height / 3.0);
    
    UTE.Tween mTw1 = app.animations.moveBy(
        _title, 
        1.5,
        vertPos, 0.0,
        UTE.Cubic.OUT, Ranger.TweenAnimation.TRANSLATE_Y, null, false);
    
    seq..push(mTw1)
      ..start();

  }
 
  @override
  void drawBackground(Ranger.DrawContext context) {
    if (!transparentBackground) {
      CanvasRenderingContext2D context2D = context.renderContext as CanvasRenderingContext2D;

      Ranger.Size<double> size = contentSize;
      context.save();

      if (_gradient == null) {
        _gradient = context2D.createLinearGradient(0.0, 0.0, 0.0, size.height);
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
