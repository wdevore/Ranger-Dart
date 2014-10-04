part of ranger_rocket;

class GameScene extends Ranger.AnchoredScene {
  Ranger.Scene _replacementScene;
  GameLayer _gameLayer;
  Ranger.GroupNode _group;

  HudLayer _hudLayer;
  
  ControlsDialog _controlsPanel;

  GameScene([int tag = 2001]) {
    this.tag = tag;
  }

  GameScene.withPrimary(Ranger.Node primary, [Ranger.Scene replacementScene, Function completeVisit]) {
    initWithPrimary(primary);
    _replacementScene = replacementScene;
  }
  
  @override
  bool init() {
    if (super.init()) {
      _group = new Ranger.GroupNode.basic();
      _group.tag = 2011;
      initWithPrimary(_group);
    
      _controlsPanel = new ControlsDialog.withHideCallback(_panelAction);

      Ranger.Application app = Ranger.Application.instance;
      // The GameScene needs to listen for events from the GameLayer
      // I do this because I don't want a tight coupling between Layer
      // and Scene.
      app.eventBus.on(MessageData).listen(
      (MessageData md) {
        switch(md.actionData) {
          case MessageData.SHOW_PANEL:
            if (!_controlsPanel.isShowing)
              _controlsPanel.show();
            break;
        }
      });
      
      //---------------------------------------------------------------
      // Main game layer where the action is. ddddaa = olive green
      //---------------------------------------------------------------
      _gameLayer = new GameLayer.withColor(Ranger.color4IFromHex("#666666"), true);
      addLayer(_gameLayer, 0, 2010);
  
      //---------------------------------------------------------------
      // A layer that overlays on top of the game layer. For example, FPS.
      //---------------------------------------------------------------
      _hudLayer = new HudLayer.asTransparent(true);
      addLayer(_hudLayer, 0, 2012);
    }    
    return true;
  }

  _panelAction(String title) {
    switch(title) {
      case "Help":
        _hudLayer.toggleHelp();
        break;
      case "HUD on/off":
        _hudLayer.visible = !_hudLayer.visible;
        break;
      case "Origin on/off":
        _gameLayer.showOriginAxis = !_gameLayer.showOriginAxis;
        break;
      case "Activate Triangle ship":
        _gameLayer.activeShip = GameLayer.TRIANGLE_SHIP;
        break;
      case "Activate DualCell ship":
        _gameLayer.activeShip = GameLayer.DUALCELL_SHIP;
        break;
    }
  }

  @override
  void onEnter() {
    super.onEnter();

    // We set the position because a transition may have changed it during
    // an animation.
    setPosition(0.0, 0.0);
  }

}
