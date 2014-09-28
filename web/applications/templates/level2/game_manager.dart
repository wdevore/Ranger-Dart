part of template2;

class GameManager {
  static final GameManager _instance = new GameManager._internal();

  GameManager._internal();
  
  Resources _resources = new Resources();
  
  // ----------------------------------------------------------
  // Instance
  // ----------------------------------------------------------
  static GameManager get instance => _instance;

  Resources get resources => _resources;
}
