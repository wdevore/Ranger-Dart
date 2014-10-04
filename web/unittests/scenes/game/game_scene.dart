part of unittests;

class GameScene extends Ranger.AnchoredScene {
  Ranger.Scene _replacementScene;
  GameLayer _gameLayer;
  Ranger.GroupNode _group;
  
  GameScene([int tag = 0]) {
    this.tag = tag;
  }
  
  GameScene.withPrimary(Ranger.Node primary, [Ranger.Scene replacementScene, Function completeVisit]) {
    initWithPrimary(primary);
    _replacementScene = replacementScene;
  }
  
  @override
  bool init([int width, int height]) {
    if (super.init()) {
      _group = new Ranger.GroupNode.basic();
      _group.tag = 2011;
      initWithPrimary(_group);
    
      //---------------------------------------------------------------
      // Main game layer where the action is. ddddaa = olive green
      //---------------------------------------------------------------
      _gameLayer = new GameLayer.withColor(Ranger.color4IFromHex("#666666"), true);
      // This two-way dependency is for this test harness.
      _gameLayer.gameScene = this;
      addLayer(_gameLayer, 0, 2010);
  
      //---------------------------------------------------------------
      // A layer that overlays on top of the game layer. For example, FPS.
      //---------------------------------------------------------------
      HudLayer hudLayer = new HudLayer.asTransparent(true);
      addLayer(hudLayer, 0, 2012);
    }    
    return true;
  }
  
  @override
  void onEnter() {
    super.onEnter();

    // We set the position because a transition may have changed it during
    // an animation.
    setPosition(0.0, 0.0);
  }
  
}
