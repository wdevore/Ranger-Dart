part of unittests;

/**
 * This test shows how to properly change transition colors.
 * Fade, Tint.
 * fill and outline.
 */
class ColorsLayer extends Ranger.BackgroundLayer {
  CanvasGradient _gradient;

  Ranger.SpriteImage _home;
  
  String startColor;
  String endColor;
  String gradStartColor;
  String gradEndColor;
  
  Ranger.TextNode _title;
  PointColor4I _fadeInOut;
  PointColorTween _fadeInOutTween;
  
  Ranger.Color4<int> _tintToColor;
  Ranger.Color4<int> _tintToOutlineColor;
  PointColorTween _tintTween;
  
  ColorsLayer();
 
  factory ColorsLayer.basic([bool centered = true, int width, int height]) {
    ColorsLayer layer = new ColorsLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = false;
    return layer;
  }

  @override
  bool init([int width, int height]) {
    super.init(width, height);

    _home = new Ranger.SpriteImage.withElement(GameManager.instance.resources.home);

    _title = new Ranger.TextNode.initWith(Ranger.color4IFromHex("#bb6600"));

    _fadeInOut = new PointColor4I.initWith(Ranger.Color4IDarkBlue, Ranger.Color4IWhite);
    _fadeInOut.outlineThickness = 10.0;
    
    _fadeInOutTween = new PointColorTween.initWith(Ranger.Color4IRed, Ranger.Color4IWhite);
    _fadeInOutTween.outlineThickness = 30.0;
    
    _tintToColor = Ranger.Color4IOrange;
    _tintToOutlineColor = Ranger.Color4IDartBlue;
    _tintTween = new PointColorTween.initWith(Ranger.Color4IGreen, Ranger.Color4IWhite);
    _tintTween.outlineThickness = 20.0;
    
    Ranger.Application app = Ranger.Application.instance;

    // Note: we don't register PointColorTween because it is a Tweenable
    // which UTE understands and expects.
    UTE.Tween.registerAccessor(Ranger.TextNode, app.animations);
    UTE.Tween.registerAccessor(PointColor4I, app.animations);

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

    // We need to terminate any animations onExit so they don't conflict
    // on any subsequent onEnter()s
    app.animations.tweenMan.killTarget(_fadeInOut, Ranger.TweenAnimation.FADE);
    app.animations.tweenMan.killTarget(_fadeInOutTween, PointColorTween.FADE_OUTLINE);
    app.animations.tweenMan.killTarget(_fadeInOutTween, PointColorTween.FADE);
    app.animations.tweenMan.killTarget(_tintTween, PointColorTween.TINT);
    app.animations.tweenMan.killTarget(_tintTween, PointColorTween.TINT_OUTLINE);
    
    // Stop previous animation so relative motion doesn't add up causing
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
    
    addChild(_home, 10, 120);
    _home.uniformScale = 5.0;
    _home.setPosition(hGap, vGap);

    //---------------------------------------------------------------
    // Create text nodes.
    //---------------------------------------------------------------
    double vDelta = -vGap * 2.0;
    _title.text = "Colors";
    _title.setPosition(hGap - (hGap * 0.15), vDelta);
    _title.strokeColor = Ranger.Color4IWhite;
    _title.strokeWidth = 1.0;
    _title.uniformScale = 5.0;
    addChild(_title, 10, 222);

    //---------------------------------------------------------------
    // Begin animating text into view.
    //---------------------------------------------------------------
    UTE.Tween mTw1 = app.animations.moveBy(
        _title, 
        2.5,
        vDelta.abs() / 2.5, 0.0,
        UTE.Cubic.OUT, Ranger.TweenAnimation.TRANSLATE_Y);
    
    //---------------------------------------------------------------
    // Fade ColorPoint4I
    //---------------------------------------------------------------
    _fadeInOut.uniformScale = 100.0;
    _fadeInOut.setPosition(-hWidth + (hWidth * 0.25), 0.0);
    addChild(_fadeInOut, 10, 1020);
    
    UTE.BaseTween fade = app.animations.fadeOut(
        _fadeInOut,
        2.0,
        UTE.Linear.INOUT,
        null,
        false);
    fade.repeatYoyo(UTE.Tween.INFINITY, 0.0);
    fade.start();

    //---------------------------------------------------------------
    // Fade ColorPointTween
    //---------------------------------------------------------------
    _fadeInOutTween.uniformScale = 150.0;
    _fadeInOutTween.setPosition(0.0, 0.0);
    addChild(_fadeInOutTween, 10, 1021);
    
    UTE.Tween fadeOut = new UTE.Tween.to(_fadeInOutTween, PointColorTween.FADE, 2.0)
      ..targetValues = [0.0]
      ..easing = UTE.Linear.INOUT
      ..repeatYoyo(UTE.Tween.INFINITY, 0.0);
      app.animations.add(fadeOut);

    UTE.Tween fadeOutline = new UTE.Tween.to(_fadeInOutTween, PointColorTween.FADE_OUTLINE, 1.5)
      ..targetValues = [0.0]
      ..easing = UTE.Linear.INOUT
      ..repeatYoyo(UTE.Tween.INFINITY, 0.0);
      app.animations.add(fadeOutline);

    //---------------------------------------------------------------
    // Tint ColorPointTween
    //---------------------------------------------------------------
    _tintTween.uniformScale = 100.0;
    _tintTween.setPosition(hWidth - (hWidth * 0.25), 0.0);
    addChild(_tintTween, 10, 1021);
    
    UTE.Tween tintFill = new UTE.Tween.to(_tintTween, PointColorTween.TINT, 2.0)
      ..targetValues = [_tintToColor.r, _tintToColor.g, _tintToColor.b]
      ..easing = UTE.Linear.INOUT
      ..repeatYoyo(UTE.Tween.INFINITY, 0.0);
      app.animations.add(tintFill);

    UTE.Tween tintOutline = new UTE.Tween.to(_tintTween, PointColorTween.TINT_OUTLINE, 2.0)
      ..targetValues = [_tintToOutlineColor.r, _tintToOutlineColor.g, _tintToOutlineColor.b]
      ..easing = UTE.Linear.INOUT
      ..repeatYoyo(UTE.Tween.INFINITY, 0.0);
      app.animations.add(tintOutline);
  }
 
  void drawBackground(Ranger.DrawContext context) {
    if (!transparentBackground) {
      CanvasRenderingContext2D context2D = context.renderContext as CanvasRenderingContext2D;

      Ranger.Size<double> size = contentSize;
      context.save();

      double ratio = size.width / size.height;
      int rows = (10 * ratio).toInt();
      int cols = (20 * ratio).toInt();
      
      double boxWidth = size.width / cols;
      double boxHeight = size.height / rows;
      double dx = 0.0;
      double dy = 0.0;
      bool alt = false;
      
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          if (alt)
            context2D.fillStyle = startColor;
          else
            context2D.fillStyle = endColor;
          context2D.fillRect(dx, dy, boxWidth, boxHeight);
          alt = !alt;
          dx += boxWidth;
        }
        alt = !alt;
        dy += boxHeight;
        dx = 0.0;
      }
      
      if (_gradient == null) {
        _gradient = context2D.createLinearGradient(0.0, 0.0, size.width, size.height);
        _gradient.addColorStop(1.0, gradStartColor);
        _gradient.addColorStop(0.0, gradEndColor);
      }

      context2D..fillStyle = _gradient
          ..fillRect(0.0, 0.0, size.width, size.height);
      
      Ranger.Application.instance.objectsDrawn++;
      
      context.restore();
    }
  }

}
