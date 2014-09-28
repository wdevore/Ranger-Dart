part of template1;

class GameManager {
  static final GameManager _instance = new GameManager._internal();

  GameManager._internal();
  
  Resources _resources = new Resources();
  
  // ----------------------------------------------------------
  // Instance
  // ----------------------------------------------------------
  static GameManager get instance => _instance;

  Resources get resources => _resources;
  bool get isBootResourcesReady => resources.isBootResourcesReady;
  bool get isBaseResourcesReady => resources.isBaseResourcesReady;

  Future bootInit() {
    return _resources.loadBootResources();
  }
  
  Future baseInit() {
    return _resources.loadBaseResources();
  }
}
