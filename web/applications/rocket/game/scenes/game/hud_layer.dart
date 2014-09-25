library hud_layer;

import 'package:ranger/ranger.dart' as Ranger;

/// Overlay layer.
class HudLayer extends Ranger.BackgroundLayer {
  Ranger.TextNode _fpsText;
  Ranger.TextNode _objectDrawnText;
  
  Ranger.GroupNode _help;
  
  HudLayer();

  factory HudLayer.asTransparent([bool centered = true, int width, int height]) {
    HudLayer layer = new HudLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = true;
    return layer;
  }

  factory HudLayer.withColor(Ranger.Color4<int> backgroundColor, [bool centered = true, int width, int height]) {
    HudLayer layer = new HudLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.color = backgroundColor;
    return layer;
  }

  @override
  void update(double dt) {
    Ranger.Application app = Ranger.Application.instance;
    if (app.updateStats) {
      // Update FPS text
      if (app.upsEnabled)
        _fpsText.text = "FPS: ${app.framesPerPeriod}, UPS: ${app.updatesPerPeriod}";
      else
        _fpsText.text = "FPS: ${app.framesPerPeriod}";
      
      app.framesPerPeriod = 0;
      app.updatesPerPeriod = 0;
      app.deltaAccum = 0.0;
      
      _objectDrawnText.text = "Drawn: ${app.objectsDrawn}";
    }
  }

  @override
  void onEnter() {
    enableKeyboard = false;
    enableTouch = false;
    
    super.onEnter();

    //---------------------------------------------------------------
    // Create nodes.
    //---------------------------------------------------------------
    _fpsText = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _fpsText.text = "--";
    _fpsText.setPosition(-position.x + 10.0, position.y - 30.0);
    _fpsText.uniformScale = 3.0;
    addChild(_fpsText, 10, 111);
     
    _objectDrawnText = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _objectDrawnText.text = "--";
    _objectDrawnText.setPosition(-position.x + 10.0, position.y - 60.0);
    _objectDrawnText.uniformScale = 3.0;
    addChild(_objectDrawnText, 10, 111);
    
    _help = new Ranger.GroupNode();
    _help.visible = false;
    _help.setPosition(-900.0, -350.0);
    addChild(_help, 10, 111);

    Ranger.TextNode key = new Ranger.TextNode.initWith(Ranger.Color4IBlack);
    key.text = "Keys:";
    key.setPosition(0.0, 0.0);
    key.uniformScale = 3.0;
    _help.addChild(key, 10, 111);

    key = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    key.text = "(A) = Counter Clockwise turning.";
    key.setPosition(0.0, -30.0);
    key.uniformScale = 3.0;
    _help.addChild(key, 10, 111);

    key = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    key.text = "(Z) = Clockwise turning.";
    key.setPosition(0.0, -60.0);
    key.uniformScale = 3.0;
    _help.addChild(key, 10, 111);

    key = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    key.text = "(/) = Thrust.";
    key.setPosition(0.0, -90.0);
    key.uniformScale = 3.0;
    _help.addChild(key, 10, 111);

    key = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    key.text = "(.) = Fire gun.";
    key.setPosition(0.0, -120.0);
    key.uniformScale = 3.0;
    _help.addChild(key, 10, 111);

    _setViewportAABBox();

    scheduleUpdate();
  }
  
  void toggleHelp() {
    _help.visible = !_help.visible;
  }
  
  // Should be called when zoom changes.
  void _setViewportAABBox() {
    Ranger.SceneManager sm = Ranger.Application.instance.sceneManager;

    double zValue = 1.0;
    
    // Note: should hold ref to scene instead of searching for it.
    Ranger.GroupingBehavior sceneGB = sm.runningScene as Ranger.GroupingBehavior;
    Ranger.BaseNode layer = sceneGB.getChildByTag(2010);
    if (layer != null) {
      layer.uniformScale = zValue;
    }

    Ranger.Application app = Ranger.Application.instance; 

    // We want the viewport to remain fixed relative to view-space.
    // Hence, if the Layer zooms in we want the viewport to do the
    // opposite.
    // Instead of mapping the viewPort Node into world-space we
    // map app.viewPortAABB to world-space.
    Ranger.DrawContext dc = app.drawContext;
    Ranger.MutableRectangle<double> worldRect = dc.mapViewRectToWorld(app.viewPortAABB);
    //print("worldRect: $worldRect");
    
    // and then for visuals we map the worldRect to the viewPort Node
    // for rendering. The viewPort Node is a centered square.
    Ranger.MutableRectangle<double> nodeRect = convertWorldRectToNode(worldRect);
    //print("nodeRect: $nodeRect");
    //viewPort.scaleTo(nodeRect.width, nodeRect.height);

    worldRect.moveToPool();
    nodeRect.moveToPool();

    app.viewPortWorldAABB.setWith(worldRect);
    
    //print("_zoomChanged: ${app.viewPortWorldAABB}");

    // Mark all Nodes dirty so that their boxes are updated as well.
    rippleDirty();
  }

}
