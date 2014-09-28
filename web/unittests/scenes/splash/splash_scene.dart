part of unittests;

class SplashScene extends Ranger.AnchoredScene {
  double pauseFor = 0.0;
  Ranger.Scene _replacementScene;
  
  SplashScene.withPrimary(Ranger.Layer primary, Ranger.Scene replacementScene, [Function completeVisit = null]) {
    initWithPrimary(primary);
    completeVisitCallback = completeVisit;
    _replacementScene = replacementScene;
  }
  
  SplashScene.withReplacementScene(Ranger.Scene replacementScene, [Function completeVisit = null]) {
    tag = 405;
    completeVisitCallback = completeVisit;
    _replacementScene = replacementScene;
  }
  
  @override
  void onEnter() {
    super.onEnter();
    
    GameManager.instance.bootInit().then(
      (_) {
        SplashLayer splashLayer = new SplashLayer.withColor(Ranger.color4IFromHex("#aa8888"), true);
        splashLayer.tag = 404;
        initWithPrimary(splashLayer);
        
        Ranger.TransitionScene transition = new Ranger.TransitionMoveInFrom.initWithDurationAndScene(0.5, _replacementScene, Ranger.TransitionMoveInFrom.FROM_LEFT);
        transition.pauseFor = pauseFor;
        transition.tag = 9090;
        
        Ranger.SceneManager sm = Ranger.Application.instance.sceneManager;
        sm.replaceScene(transition);
      });
    }
}
