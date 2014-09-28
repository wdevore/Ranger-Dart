part of unittests;

/**
 * Shows the mouse's location relative to different nodes.
 * 
 */
class SpacesLayer extends Ranger.BackgroundLayer {
  CanvasGradient _gradient;

  Ranger.SpriteImage _home;
  Ranger.SpriteSheetImage _gTypeSheet;
  
  Ranger.CanvasSprite _gTypeRocket;
  Ranger.CanvasSprite _gTypeRocket2;
  Ranger.SpriteImage _rocket;
  Ranger.SpriteImage _rocket2;
  Ranger.SpriteImage _rocketPng;
  Ranger.SpriteImage _rocketPng2;

  GridNode _grid;
  
  Ranger.TextNode _layerCoords;
  Ranger.TextNode _localCoords;
  Ranger.TextNode _parentCoords;
  Ranger.TextNode _viewCoords;
  Ranger.TextNode _name;
  
  String startColor;
  String endColor;
  
  SpacesLayer();
 
  factory SpacesLayer.basic([bool centered = true, int width, int height]) {
    SpacesLayer layer = new SpacesLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = false;
    layer.showOriginAxis = true;
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
    Ranger.Application app = Ranger.Application.instance;
    _grid = new GridNode.withDimensions(app.designSize.width, app.designSize.height, true);
    
    _rocket = new Ranger.SpriteImage.withElement(GameManager.instance.resources.rocket2);
    _rocket2 = new Ranger.SpriteImage.withElement(GameManager.instance.resources.rocket2);
    _rocketPng = new Ranger.SpriteImage.withElement(GameManager.instance.resources.colorRocket);
    _rocketPng2 = new Ranger.SpriteImage.withElement(GameManager.instance.resources.colorRocket);

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
  bool onMouseMove(MouseEvent event) {
    Ranger.Application app = Ranger.Application.instance;

    double textLayerOffset = -40.0;
    double textLocalOffset = -65.0;
    
    Ranger.Vector2P layerP = app.drawContext.mapViewToNode(this, event.offset.x, event.offset.y);
    _layerCoords.text = "Layer (${layerP.v.x.toStringAsFixed(2)}, ${layerP.v.y.toStringAsFixed(2)})";
    _layerCoords.setPosition(layerP.v.x, layerP.v.y + textLayerOffset);

    _viewCoords.text = "View (${event.offset.x}, ${event.offset.y})";
    _viewCoords.setPosition(layerP.v.x - 180.0, layerP.v.y - 40.0);

    _name.setPosition(layerP.v.x + 10.0, layerP.v.y - 10.0);
    _name.text = "";
    _localCoords.text = "";
    _parentCoords.text = "";
    
    bool hit = _setLocalLabel(
        layerP.v, _gTypeRocket, 
        event.offset.x, event.offset.y, 
        0.0, textLocalOffset, "Sprite 64x64, scale: 3.0");
    
    if (hit) {
      _setParentLabel(layerP.v, _gTypeRocket, event.offset.x, event.offset.y);
      layerP.moveToPool();
      return true;
    }

    hit = _setLocalLabel(
        layerP.v, _gTypeRocket2, 
        event.offset.x, event.offset.y, 
        0.0, textLocalOffset, "Sprite 64x64, scale: 1.0");
    
    if (hit) {
      _setParentLabel(layerP.v, _gTypeRocket2, event.offset.x, event.offset.y);
      layerP.moveToPool();
      return true;
    }

    hit = _setLocalLabel(
        layerP.v, _rocket, 
        event.offset.x, event.offset.y, 
        0.0, textLocalOffset, "SVG 613x586, scale: 0.3");
    
    if (hit) {
      _setParentLabel(layerP.v, _rocket, event.offset.x, event.offset.y);
      layerP.moveToPool();
      return true;
    }

    hit = _setLocalLabel(
        layerP.v, _rocket2, 
        event.offset.x, event.offset.y, 
        0.0, textLocalOffset, "SVG 613x586, scale: 0.5, rot: -45.0");
    
    if (hit) {
      _setParentLabel(layerP.v, _rocket2, event.offset.x, event.offset.y);
      layerP.moveToPool();
      return true;
    }

    hit = _setLocalLabel(
        layerP.v, _rocketPng, 
        event.offset.x, event.offset.y, 
        0.0, textLocalOffset, "PNG 128x128, scale: 2.0");
    
    if (hit) {
      _setParentLabel(layerP.v, _rocketPng, event.offset.x, event.offset.y);
      layerP.moveToPool();
      return true;
    }

    hit = _setLocalLabel(
        layerP.v, _rocketPng2, 
        event.offset.x, event.offset.y, 
        0.0, textLocalOffset, "PNG 128x128, scale: 1.0");
    
    if (hit) {
      _setParentLabel(layerP.v, _rocketPng2, event.offset.x, event.offset.y);
      layerP.moveToPool();
      return true;
    }

    // We move the layerP object to the pool last. If we move it to soon
    // it will be recycled during the nodeP allocation. So we "hold" on
    // it until the end.
    layerP.moveToPool();
    return true;
  }

  // Note: this isn't calculating correctly when rotations are present.
  void _setParentLabel(Vector2 layer, Ranger.Node node, int mx, int my) {
//    Ranger.Application app = Ranger.Application.instance;
//    Ranger.AffineTransform at = node.calcScaleRotationComponents();
//    Ranger.Vector2P nodeP = app.drawContext.mapViewToNode(node, mx, my);
//    at.ApplyToVectorPoint(nodeP.v);
//    _parentCoords.text = "Parent (${nodeP.v.x.toStringAsFixed(2)}, ${nodeP.v.y.toStringAsFixed(2)})";
//    _parentCoords.setPosition(layer.x, layer.y - 90.0);
//    nodeP.moveToPool();
//    at.moveToPool();
  }
  
  bool _setLocalLabel(Vector2 layer, Ranger.Node node, int mx, int my, double offX, double offY, String name) {
    Ranger.Application app = Ranger.Application.instance;

    Ranger.Vector2P nodeP = app.drawContext.mapViewToNode(node, mx, my);
    nodeP.moveToPool();
    
    // TODO Argh! this type casting needs to fixed at the node level.
    if (node is Ranger.SpriteImage) {
      if (node.containsPoint(nodeP.v)) {
        _localCoords.text = "Local (${nodeP.v.x.toStringAsFixed(2)}, ${nodeP.v.y.toStringAsFixed(2)})";
        _localCoords.setPosition(layer.x + offX, layer.y + offY);
        _name.text = name;
        return true;
      }
    }
    else if (node is Ranger.CanvasSprite) {
      if (node.containsPoint(nodeP.v)) {
        _localCoords.text = "Local (${nodeP.v.x.toStringAsFixed(2)}, ${nodeP.v.y.toStringAsFixed(2)})";
        _localCoords.setPosition(layer.x + offX, layer.y + offY);
        _name.text = name;
        return true;
      }
    }
    
    return false;
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

    _grid.majorColor = Ranger.color4IFromHex("#512a44").toString();
    _grid.minorColor = Ranger.color4IFromHex("#d5c2d8").toString();
    
    addChild(_grid, 9, 343);
    
    //---------------------------------------------------------------
    // Create text nodes.
    //---------------------------------------------------------------
    Ranger.TextNode title = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    title.text = "Space Mappings";
    title.font = "monaco";
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

    _gTypeRocket = new Ranger.CanvasSprite.initWith(_gTypeSheet);
    addChild(_gTypeRocket, 10, 450);
    _gTypeRocket.setPosition(-150.0, 200.0);
    _gTypeRocket.aabboxVisible = true;
    _gTypeRocket.uniformScale = 3.0;
    _gTypeRocket.changeFrameRate(15);
    app.scheduler.scheduleTimingTarget(_gTypeRocket);

    _gTypeRocket2 = new Ranger.CanvasSprite.initWith(_gTypeSheet);
    addChild(_gTypeRocket2, 10, 455);
    _gTypeRocket2.setPosition(100.0, 200.0);
    _gTypeRocket2.aabboxVisible = true;
    _gTypeRocket2.changeFrameRate(15);
    app.scheduler.scheduleTimingTarget(_gTypeRocket2);

    addChild(_rocket, 10, 451);
    _rocket.uniformScale = 0.3;
    _rocket.aabboxVisible = true;
    _rocket.setPosition(-150.0, -250.0);

    addChild(_rocket2, 10, 451);
    _rocket2.uniformScale = 1.0;
    _rocket2.rotationByDegrees = 45.0;
    _rocket2.aabboxVisible = true;
    _rocket2.setPosition(300.0, -100.0);

    addChild(_rocketPng, 10, 452);
    _rocketPng.uniformScale = 2.0;
    _rocketPng.rotationByDegrees = -45.0;
    _rocketPng.aabboxVisible = true;
    _rocketPng.setPosition(-400.0, 0.0);

    addChild(_rocketPng2, 10, 452);
    _rocketPng2.aabboxVisible = true;
    _rocketPng2.setPosition(-400.0, -230.0);

    _layerCoords = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _layerCoords.text = "";
    _layerCoords.font = "monaco";
    _layerCoords.shadows = false;
    _layerCoords.uniformScale = 2.0;
    addChild(_layerCoords, 10, 222);
    
    _localCoords = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _localCoords.text = "";
    _localCoords.font = "monaco";
    _localCoords.shadows = false;
    _localCoords.uniformScale = 2.0;
    addChild(_localCoords, 10, 223);
    
    _parentCoords = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _parentCoords.text = "";
    _parentCoords.font = "monaco";
    _parentCoords.shadows = false;
    _parentCoords.uniformScale = 2.0;
    addChild(_parentCoords, 10, 224);
    
    _viewCoords = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _viewCoords.text = "";
    _viewCoords.font = "monaco";
    _viewCoords.shadows = false;
    _viewCoords.uniformScale = 2.0;
    addChild(_viewCoords, 10, 225);
    
    _name = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _name.text = "";
    _name.font = "monaco";
    _name.shadows = false;
    _name.uniformScale = 2.0;
    addChild(_name, 10, 223);
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
