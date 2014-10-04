part of template0;

class GameScene extends Ranger.AnchoredScene {
  Ranger.Scene _replacementScene;
  GameLayer _gameLayer;
  Ranger.GroupNode _group;
  
  GameScene([int tag = 0]) {
    this.tag = tag;
  }
  
  @override
  bool init([int width, int height]) {
    if (super.init()) {
      _group = new Ranger.GroupNode.basic();
      _group.tag = 2011; // An optional arbitrary number usual for debugging.
      initWithPrimary(_group);
    
      //---------------------------------------------------------------
      // Main game layer where the action is. ddddaa = olive green
      //---------------------------------------------------------------
      _gameLayer = new GameLayer.withColor(Ranger.color4IFromHex("#666666"), true);
      addLayer(_gameLayer, 0, 2010);
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
