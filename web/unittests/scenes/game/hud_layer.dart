part of unittests;

/// Overlay layer.
class HudLayer extends Ranger.BackgroundLayer {
  Ranger.TextNode _fpsText;
  Ranger.TextNode _objectDrawnText;
  
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
  bool init([int width, int height]) {
    super.init(width, height);
    
    _fpsText = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _fpsText.text = "--";
    _fpsText.setPosition(-position.x + 10.0, position.y - 20.0);
    _fpsText.uniformScale = 2.0;
    addChild(_fpsText, 10, 8111);
     
    _objectDrawnText = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _objectDrawnText.text = "--";
    _objectDrawnText.setPosition(-position.x + 10.0, position.y - 40.0);
    _objectDrawnText.uniformScale = 2.0;
    addChild(_objectDrawnText, 10, 8112);
    
    return true;
  }

  @override
  void onEnter() {
    enableKeyboard = false;
    enableTouch = false;
    
    super.onEnter();

    scheduleUpdate();
  }
  
  @override
  void onExit() {
    super.onExit();
    unScheduleUpdate();
  }
}
