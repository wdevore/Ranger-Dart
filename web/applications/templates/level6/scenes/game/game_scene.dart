library game_scene;

import 'package:ranger/ranger.dart' as Ranger;

import 'game_layer.dart';

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
      _group = new Ranger.GroupNode();
      _group.tag = 2011; // An optional arbitrary number typically for debugging.
      initWithPrimary(_group);
    
      //---------------------------------------------------------------
      // Main game layer where the action is. ddddaa = olive green
      //---------------------------------------------------------------
      _gameLayer = new GameLayer.withColor(Ranger.color4IFromHex("#333333"), true);
      addLayer(_gameLayer, 0, 2010);
    }    
    return true;
  }
  
  @override
  void onEnter() {
    print("GameScene.onEnter tag:$tag");
    super.onEnter();

    // We set the position because a Transition may have changed it during
    // an animation.
    setPosition(0.0, 0.0);
  }
  
}
