part of template2;

class SplashScene extends Ranger.AnchoredScene {
  /**
   * How long to pause (in seconds) before transitioning to the [_replacementScene]
   * [Scene]. Default is immediately (aka 0.0)
   */
  double pauseFor = 0.0;
  Ranger.Scene _replacementScene;
  
  SplashScene.withPrimary(Ranger.Layer primary, Ranger.Scene replacementScene, [Function completeVisit = null]) {
    initWithPrimary(primary);
    completeVisitCallback = completeVisit;
    _replacementScene = replacementScene;
  }
  
  SplashScene.withReplacementScene(Ranger.Scene replacementScene, [Function completeVisit = null]) {
    tag = 405;  // An optional arbitrary number usual for debugging.
    completeVisitCallback = completeVisit;
    _replacementScene = replacementScene;
  }
  
  @override
  void onEnter() {
    super.onEnter();
    
    SplashLayer splashLayer = new SplashLayer.withColor(Ranger.color4IFromHex("#aa8888"), true);
    splashLayer.tag = 404;
    initWithPrimary(splashLayer);

    Ranger.TransitionScene transition = new Ranger.TransitionInstant.initWithScene(_replacementScene);
    transition.pauseFor = pauseFor;
    transition.tag = 9090;
    
    Ranger.SceneManager sm = Ranger.Application.instance.sceneManager;
    sm.replaceScene(transition);
  }
}