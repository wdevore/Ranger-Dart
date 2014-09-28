part of unittests;

/**
 * This test shows how to properly transform [Node]s.  
 */
class TransformsLayer extends Ranger.BackgroundLayer {
  CanvasGradient _gradient;

  Ranger.SpriteImage _home;
  
  String startColor;
  String endColor;
  
  Ranger.TextNode _title;
  Ranger.TextNode _translation;
  Ranger.TextNode _rotation;
  Ranger.TextNode _scale;
  RectangleNode _rotationNode;
  PointColor _scaleNode;
  PointColor _translationNode;
  
  TransformsLayer();
 
  factory TransformsLayer.basic([bool centered = true, int width, int height]) {
    TransformsLayer layer = new TransformsLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = false;
    return layer;
  }

  @override
  bool init([int width, int height]) {
    super.init(width, height);

    _home = new Ranger.SpriteImage.withElement(GameManager.instance.resources.home);

    _title = new Ranger.TextNode.initWith(Ranger.color4IFromHex("#425563"));
    _translation = new Ranger.TextNode.initWith(Ranger.color4IFromHex("#009639"));
    _rotation = new Ranger.TextNode.initWith(Ranger.color4IFromHex("#7d3f16"));
    _scale = new Ranger.TextNode.initWith(Ranger.color4IFromHex("#93272c"));

    _rotationNode = new RectangleNode.basic();
    _scaleNode = new PointColor.initWith(null);
    _translationNode = new PointColor.initWith(null);

    Ranger.Application app = Ranger.Application.instance;

    UTE.Tween.registerAccessor(PointColor, app.animations);
    UTE.Tween.registerAccessor(RectangleNode, app.animations);
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
  void onExit() {
    super.onExit();

    // We need to terminate any animations onExit so they don't conflict
    // on any subsequent onEnter
    Ranger.Application app = Ranger.Application.instance;
    app.animations.tweenMan.killTarget(_rotationNode, Ranger.TweenAnimation.ROTATE);
    app.animations.tweenMan.killTarget(_scaleNode, Ranger.TweenAnimation.SCALE_XY);
    app.animations.tweenMan.killTarget(_translationNode, Ranger.TweenAnimation.TRANSLATE_XY);
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
    _title.text = "Transforms";
    _title.setPosition(hGap - (hGap * 0.75), vDelta);
    _title.strokeColor = Ranger.Color4IWhite;
    _title.strokeWidth = 1.0;
    _title.uniformScale = 10.0;
    addChild(_title, 10, 222);

    _rotation.text = "Rotation";
    _rotation.setPosition(-hWidth + (hWidth * 0.1), vGap - (vGap * 0.25));
    _rotation.strokeColor = Ranger.Color4IWhite;
    _rotation.strokeWidth = 1.0;
    _rotation.uniformScale = 7.0;
    addChild(_rotation, 10, 222);

    _translation.text = "Translation";
    _translation.setPosition(-hWidth + (hWidth * 0.1), 0.0);
    _translation.strokeColor = Ranger.Color4IWhite;
    _translation.strokeWidth = 1.0;
    _translation.uniformScale = 7.0;
    addChild(_translation, 10, 222);

    _scale.text = "Scale";
    _scale.setPosition(-hWidth + (hWidth * 0.1), -vGap + (vGap * 0.25));
    _scale.strokeColor = Ranger.Color4IWhite;
    _scale.strokeWidth = 1.0;
    _scale.uniformScale = 7.0;
    addChild(_scale, 10, 222);
    
    _rotationNode.fillColor = Ranger.Color4IWhite.toString();
    _rotationNode.drawColor = Ranger.Color4IBlack.toString();
    _rotationNode.uniformScale = 100.0;
    _rotationNode.setPosition(_rotation.position.x + 400.0, _rotation.position.y);
    addChild(_rotationNode, 10, 1010);

    UTE.Tween rot = app.animations.rotateBy(
        _rotationNode, 
        2.5,
        360.0, 
        UTE.Linear.INOUT, null, false);
    // Above we set "autostart" to false in order to set the repeat value
    // because you can't change the value after the tween has started.
    rot.repeat(UTE.Tween.INFINITY, 0.0);
    rot.start();
    
    _scaleNode.fillColor = Ranger.Color4IDarkBlue.toString();
    _scaleNode.outlineColor = Ranger.Color4IWhite.toString();
    _scaleNode.uniformScale = 5.0;
    _scaleNode.setPosition(_scale.position.x + 400.0, _scale.position.y);
    addChild(_scaleNode, 10, 1010);

    UTE.BaseTween scaleUp = app.animations.scaleTo(
        _scaleNode, 2.0,
        25.0, 25.0,
        UTE.Linear.INOUT,
        Ranger.TweenAnimation.SCALE_XY, null,
        Ranger.TweenAnimation.MULTIPLY, false);
    scaleUp.repeatYoyo(UTE.Tween.INFINITY, 0.0);
    scaleUp.start();

    _translationNode.fillColor = Ranger.Color4ISkin.toString();
    _translationNode.outlineColor = Ranger.Color4IWhite.toString();
    _translationNode.uniformScale = 25.0;
    _translationNode.setPosition(_translation.position.x + 400.0, _translation.position.y);
    addChild(_translationNode, 10, 1010);

    UTE.BaseTween right = app.animations.moveTo(
        _translationNode, 2.0,
        250.0, 0.0,
        UTE.Linear.INOUT,
        Ranger.TweenAnimation.TRANSLATE_XY, null,
        false);
    right.repeatYoyo(UTE.Tween.INFINITY, 0.0);
    right.start();

    //---------------------------------------------------------------
    // Begin animating text into view.
    //---------------------------------------------------------------
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
        _gradient = context2D.createLinearGradient(0.0, 0.0, 0.0, size.height);
        _gradient.addColorStop(1.0, startColor);
        _gradient.addColorStop(0.0, endColor);
      }

      context2D..fillStyle = _gradient
          ..fillRect(0.0, 0.0, size.width, size.height);
      
      Ranger.Application.instance.objectsDrawn++;
      
      context.restore();
    }
  }

}
