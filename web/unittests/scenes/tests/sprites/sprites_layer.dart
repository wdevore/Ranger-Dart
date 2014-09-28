part of unittests;

/**
 * Layer has 4 arrow buttons for transitioning in 4 directions.
 * 
 */
class SpritesLayer extends Ranger.BackgroundLayer {
  CanvasGradient _gradient;

  Ranger.SpriteImage _home;
  Ranger.SpriteSheetImage _gTypeSheet;
  
  String startColor;
  String endColor;
  
  SpritesLayer();
 
  factory SpritesLayer.basic([bool centered = true, int width, int height]) {
    SpritesLayer layer = new SpritesLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = false;
    return layer;
  }

  @override
  bool init([int width, int height]) {
    super.init(width, height);

    _home = new Ranger.SpriteImage.withElement(GameManager.instance.resources.home);

    Ranger.Application app = Ranger.Application.instance;
    UTE.Tween.registerAccessor(Ranger.TextNode, app.animations);

    _gTypeSheet = new Ranger.SpriteSheetImage("resources/gtype.json");
    _gTypeSheet.load(_spriteLoaded);

    return true;
  }
  
  void _spriteLoaded() {
    _configure();
  }
  
  @override
  void onEnter() {
    enableMouse = true;
    super.onEnter();
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
  
  @override
  void onExit() {
    super.onExit();
    Ranger.Application app = Ranger.Application.instance;
    app.animations.tweenMan.killTarget(_home, Ranger.TweenAnimation.TRANSLATE_Y);
  }

  void _configure() {
    Ranger.Application app = Ranger.Application.instance;
    
    double hHeight = app.designSize.height / 2.0;
    double hWidth = app.designSize.width / 2.0;
    double hGap = hWidth - (hWidth * 0.25);
    double vGap = hHeight - (hHeight * 0.25);
    
    addChild(_home, 10, 120);
    _home.uniformScale = 5.0;
    _home.setPosition(hGap, vGap);

    //---------------------------------------------------------------
    // Create text nodes.
    //---------------------------------------------------------------
    Ranger.TextNode title = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    title.text = "Sprites";
    title.font = "10px monaco";
    title.font = null;
    title.shadows = false;
    title.setPosition(-hGap - 150.0, vGap - 90.0);
    title.uniformScale = 5.0;
    addChild(title, 10, 222);

    //---------------------------------------------------------------
    // Begin animating text into view.
    //---------------------------------------------------------------
    // Because the TextNode isn't a Tweenable we need to register the 
    // class with the Tween system in order to recognize and animate it.
    UTE.Tween.registerAccessor(Ranger.TextNode, app.animations);

    UTE.Timeline seq = new UTE.Timeline.sequence();
    
    double vertPos = hHeight - (app.designSize.height / 3.0);
    
    UTE.Tween mTw1 = app.animations.moveBy(
        title, 
        1.5,
        vertPos, 0.0,
        UTE.Cubic.OUT, Ranger.TweenAnimation.TRANSLATE_Y, null, false);
    
    seq..push(mTw1)
       ..start();

    Ranger.Sprite sprite1 = new Ranger.CanvasSprite.initWith(_gTypeSheet);
    sprite1.setPosition(-175.0, 0.0);
    addChild(sprite1, 10, 443);
    sprite1.changeFrameRate(1);
    app.scheduler.scheduleTimingTarget(sprite1);

    Ranger.Sprite sprite5 = new Ranger.CanvasSprite.initWith(_gTypeSheet);
    sprite5.setPosition(-100.0, 0.0);
    sprite5.uniformScale = 1.5;
    addChild(sprite5, 10, 443);
    sprite5.changeFrameRate(5);
    app.scheduler.scheduleTimingTarget(sprite5);

    Ranger.Sprite sprite15 = new Ranger.CanvasSprite.initWith(_gTypeSheet);
    sprite15.setPosition(0.0, 0.0);
    sprite15.uniformScale = 2.0;
    addChild(sprite15, 10, 446);
    sprite15.changeFrameRate(15);
    app.scheduler.scheduleTimingTarget(sprite15);

    Ranger.Sprite sprite30 = new Ranger.CanvasSprite.initWith(_gTypeSheet);
    sprite30.setPosition(150.0, 0.0);
    sprite30.uniformScale = 2.5;
    addChild(sprite30, 10, 445);
    sprite30.changeFrameRate(30);
    app.scheduler.scheduleTimingTarget(sprite30);

    Ranger.Sprite sprite60 = new Ranger.CanvasSprite.initWith(_gTypeSheet);
    sprite60.setPosition(300.0, 0.0);
    sprite60.uniformScale = 3.0;
    addChild(sprite60, 10, 444);
    sprite60.changeFrameRate(60);
    app.scheduler.scheduleTimingTarget(sprite60);
  }
 
  @override
  void drawBackground(Ranger.DrawContext context) {
    if (!transparentBackground) {
      CanvasRenderingContext2D context2D = context.renderContext as CanvasRenderingContext2D;

      Ranger.Size<double> size = contentSize;
      context.save();

      if (_gradient == null) {
        _gradient = context2D.createLinearGradient(0.0, size.height * 3.0, size.width, size.height);
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
