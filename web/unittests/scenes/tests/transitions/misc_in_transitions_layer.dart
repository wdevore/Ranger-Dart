part of unittests;

/**
 */
class MiscInTransitionsLayer extends Ranger.BackgroundLayer {
  CanvasGradient _gradient;

  Ranger.SpriteImage _fan;
  Ranger.SpriteImage _grow;
  Ranger.SpriteImage _rotate;
  Ranger.SpriteImage _home;
  
  String startColor;
  String endColor;
  
  Ranger.TextNode _title;
  
  MiscInTransitionsLayer();
 
  factory MiscInTransitionsLayer.basic([bool centered = true, int width, int height]) {
    MiscInTransitionsLayer layer = new MiscInTransitionsLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = false;
    return layer;
  }

  @override
  bool init([int width, int height]) {
    super.init(width, height);

    _fan = new Ranger.SpriteImage.withElement(GameManager.instance.resources.cycle);
    _grow = new Ranger.SpriteImage.withElement(GameManager.instance.resources.expand);
    _rotate = new Ranger.SpriteImage.withElement(GameManager.instance.resources.feed);
    
    _home = new Ranger.SpriteImage.withElement(GameManager.instance.resources.home);

    _title = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _title.strokeColor = Ranger.Color4IRed;
    _title.strokeWidth = 0.3;

    _configure();
    
    return true;
  }
  
  @override
  void onEnter() {
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
    Ranger.Vector2P nodeP = app.drawContext.mapViewToNode(_fan, event.offset.x, event.offset.y);
    nodeP.moveToPool();

    if (_fan.containsPoint(nodeP.v)) {
      // The incoming Scene is the previous Scene.
      Ranger.Application app = Ranger.Application.instance;
      MiscTransitionsScene inComingScene = new MiscTransitionsScene();
      inComingScene.backgroundGradient(Ranger.color4IFromHex("#ffffff77"), Ranger.color4IFromHex("#4a3041cc"));
      inComingScene.tag = 1610;
      
      Ranger.TransitionScene transition = new Ranger.TransitionFanInFanOut.initWithDurationAndScene(1.5, inComingScene);
      transition.tag = 9098;
      
      app.sceneManager.replaceScene(transition);
      return true;
    }
    
    nodeP = app.drawContext.mapViewToNode(_grow, event.offset.x, event.offset.y);
    nodeP.moveToPool();
    if (_grow.containsPoint(nodeP.v)) {
      Ranger.Application app = Ranger.Application.instance;
      MiscTransitionsScene inComingScene = new MiscTransitionsScene();
      inComingScene.backgroundGradient(Ranger.color4IFromHex("#ffffff77"), Ranger.color4IFromHex("#4a3041cc"));
      inComingScene.tag = 1610;
      
      Ranger.TransitionScene transition = new Ranger.TransitionShrinkGrow.initWithDurationAndScene(1.5, inComingScene);
      transition.tag = 9098;
      
      app.sceneManager.replaceScene(transition);
      return true;
    }
    
    nodeP = app.drawContext.mapViewToNode(_rotate, event.offset.x, event.offset.y);
    nodeP.moveToPool();
    if (_rotate.containsPoint(nodeP.v)) {
      Ranger.Application app = Ranger.Application.instance;
      MiscTransitionsScene inComingScene = new MiscTransitionsScene();
      inComingScene.backgroundGradient(Ranger.color4IFromHex("#ffffff77"), Ranger.color4IFromHex("#4a3041cc"));
      inComingScene.tag = 1610;
      
      Ranger.TransitionScene transition = new Ranger.TransitionRotateAndZoom.initWithDurationAndScene(2.0, inComingScene);
      transition.tag = 9098;
      
      app.sceneManager.replaceScene(transition);
      return true;
    }

    nodeP = app.drawContext.mapViewToNode(_home, event.offset.x, event.offset.y);
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

    //---------------------------------------------------------------
    // Create text nodes.
    //---------------------------------------------------------------
    double vDelta = -vGap * 2.0;

    _title.text = "Miscellaneous transitions";
    _title.setPosition(-hGap + (hGap * 0.2), vDelta);
    _title.uniformScale = 7.0;
    addChild(_title, 10, 222);

    //---------------------------------------------------------------
    // Create icon nodes.
    //---------------------------------------------------------------
    addChild(_fan, 10, 117);
    _fan.uniformScale = 5.0;
    _fan.setPosition(-hGap, 0.0);

    addChild(_grow, 10, 118);
    _grow.uniformScale = 5.0;
    _grow.setPosition(0.0, 0.0);

    addChild(_rotate, 10, 119);
    _rotate.uniformScale = 5.0;
    _rotate.setPosition(hGap, 0.0);

    addChild(_home, 10, 120);
    _home.uniformScale = 5.0;
    _home.setPosition(hGap, vGap);

    //---------------------------------------------------------------
    // Begin animating text into view.
    //---------------------------------------------------------------
    // Because the TextNode isn't a Tweenable we need to register the 
    // class with the Tween system in order to recognize and animate it.
    UTE.Tween.registerAccessor(Ranger.TextNode, app.animations);
    
    _animateText(_title, vDelta);
  }
 
  void _animateText(Ranger.BaseNode node, double vDelta) {
    Ranger.Application app = Ranger.Application.instance;
    
    // Stop any previous animation so relative motion doesn't add up causing
    // the target to animate offscreen.
    app.animations.tweenMan.killTarget(node, Ranger.TweenAnimation.TRANSLATE_Y);
    
    UTE.Timeline seq = new UTE.Timeline.sequence();
    
    UTE.Tween mTw1 = app.animations.moveBy(
        node, 
        2.5,
        vDelta.abs() / 2.0, 0.0,
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

      int bars = 30;
      Ranger.Application app = Ranger.Application.instance;
      double hHeight = app.designSize.height / 2.0;
      double hWidth = app.designSize.width / 2.0;
      double barWidth = app.designSize.width / bars;
      
      int tagId = 200;
      double barX = 0.0;
      bool odd = false;
      for(int c = 0; c < bars; c++) {
        if (odd)
          context2D.fillStyle = Ranger.color4IFromHex("#f4364c").toString();//d4b59e
        else
          context2D.fillStyle = Ranger.color4IFromHex("#fb637e").toString();//c07d59
        
        context2D.fillRect(barX, 0.0, barWidth, size.height);
        
        odd = !odd;
        barX += barWidth;
      }

      if (_gradient == null) {
        _gradient = context2D.createLinearGradient(0.0, 0.0, size.width, size.height);
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
