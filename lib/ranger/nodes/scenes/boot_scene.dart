part of ranger;

/**
 * [BootScene] is a very brief and transient Scene. Its sole purpose is
 * as a standin during application boot. See unit tests and templates.
 */
class BootScene extends Scene {
  Scene _replacementScene;
  bool _autoTransition;
  
  /**
   * [BootScene]'s tag id is 12012.
   * [replacementScene] is the scene you want the BootScene replaced
   * with once the browser and [Ranger] have booted. If it is omitted
   * then nothing happens. You game will simply sit and show the canvas
   * clear color which defaults to Orange.
   * [autoTransition] default to true an is the natural setting.
   */
  BootScene([Scene replacementScene, bool autoTransition = true]) {
    tag = 12012;
    _autoTransition = autoTransition;
    _replacementScene = replacementScene;
  }
  
  @override
  void onEnter() {
    //print("BootScene.onEnter $tag");
    super.onEnter();
    if (_replacementScene != null && _autoTransition) {
      forceTransition();
    }
  }
  
  void forceTransition() {
    SceneManager sm = Application.instance.sceneManager;
    //print("BootScene.forceTransition to ${_replacementScene.tag}");
    sm.replaceScene(_replacementScene);
  }
  
}
