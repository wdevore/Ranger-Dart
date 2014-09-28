part of unittests;

/**
 * Layer has 4 arrow buttons for transitioning in 4 directions.
 * 
 */
class FontsLayer extends Ranger.BackgroundLayer {
  CanvasGradient _gradient;

  Ranger.SpriteImage _home;
  Ranger.TextNode _fantasy;
  
  String startColor;
  String endColor;
  
  FontsLayer();
 
  factory FontsLayer.basic([bool centered = true, int width, int height]) {
    FontsLayer layer = new FontsLayer();
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
    app.animations.tweenMan.killTarget(_fantasy, Ranger.TweenAnimation.ROTATE);
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
    title.text = "Fonts";
    title.font = null;
    title.shadows = false;
    title.setPosition(-hGap - 150.0, vGap - 90.0);
    title.uniformScale = 3.0;
    addChild(title, 10, 222);

    Ranger.TextNode palatino = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    palatino.text = "100px Palatino";
    palatino.font = palatino.text;
    palatino.shadows = false;
    palatino.setPosition(-hGap - 150.0, vGap - 90.0);
    palatino.uniformScale = 1.0;
    addChild(palatino, 10, 222);

    Ranger.TextNode ariel = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    ariel.text = "かんぱい (Cheers)";
    ariel.font = "80px monaco";
    ariel.shadows = true;
    ariel.setPosition(-hGap - 100.0, vGap - 220.0);
    ariel.uniformScale = 1.0;
    addChild(ariel, 10, 222);

    Ranger.TextNode monaco = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    monaco.text = "80px monaco";
    monaco.font = monaco.text;
    monaco.shadows = true;
    monaco.setPosition(-hGap - 150.0, vGap - 330.0);
    monaco.uniformScale = 1.0;
    addChild(monaco, 10, 222);

    _fantasy = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _fantasy.text = "100px fantasy";
    _fantasy.font = _fantasy.text;
    _fantasy.shadows = true;
    _fantasy.setPosition(-hGap - 50.0, vGap - 430.0);
    _fantasy.uniformScale = 1.0;
    addChild(_fantasy, 10, 222);

    UTE.Tween rot = app.animations.rotateBy(
        _fantasy, 
        2.5,
        -20.0, 
        UTE.Cubic.INOUT, null, false);
    // Above we set "autostart" to false in order to set the repeat value
    // because you can't change the value after the tween has started.
    rot.repeatYoyo(UTE.Tween.INFINITY, 0.0);
    rot.start();

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
