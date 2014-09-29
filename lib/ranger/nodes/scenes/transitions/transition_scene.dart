part of ranger;

/**
 * [TransitionScene] manages the transition from an Incoming [Scene] to
 * an Outgoing [Scene].
 */
abstract class TransitionScene extends Scene {
  Scene inScene;
  Scene outScene;
  double duration;
  double pauseFor = 0.0;
  
  bool inSceneOnTop = false;
  bool sendCleanupToScene = false;

  bool initWithDuration(double duration, Scene scene) {
    if (super.init()) {
      this.duration = duration;
      position.setValues(0.0, 0.0);
      inScene = scene;

      SceneManager sm = Application.instance.sceneManager;

      outScene = sm.runningScene;
      
      if (outScene == null) {
        outScene = new BasicScene();
        outScene.init();
      }

      if (inScene == outScene) {
        Logging.error("TransitionScene.initWithDuration(): Incoming scene must be different from the outgoing scene");
        return false;
      }

      inSceneOnTop = true;

      return true;
    }
    
    return false;
  }
  
  /// called when a transition finishes
  void finish(Object data) {
    inScene.visible = true;
    
    // The position of the incoming scene needs to respect any
    // Anchor parenting information.
    if (!(inScene is Scene)) {
      inScene.position.setValues(0.0, 0.0);
    }
    
    if (inScene is AnchoredScene) {
      inScene.anchor.uniformScale = 1.0;
      inScene.anchor.rotation = 0.0;
    }
    else {
      inScene.uniformScale = 1.0;
      inScene.rotation = 0.0;
    }
    
    // TODO WebGL, use context polymorph
    //if(cc.renderContextType === cc.WEBGL)
    //  inScene.getCamera().restore();

    if (!(outScene is Scene)) {
      outScene.position.setValues(0.0, 0.0);
    }
    if (outScene is AnchoredScene) {
      // Resetting these causes flashing because the outgoing scene
      // hasn't actually Exited or become Invisible.
      // It is the duty of the incoming scene to configure itself for the
      // animation prior to activation.
      //outScene.anchor.uniformScale = 1.0;
      //outScene.anchor.rotation = 0.0;
    }
    else {
      outScene.uniformScale = 1.0;
      outScene.rotation = 0.0;
    }
    
    // TODO WebGL
    //if(cc.renderContextType === cc.WEBGL)
    //  outScene.getCamera().restore();

    // TODO consider replacing this odd usage of UpdateTarget with
    // a EventBus call instead.
    Scheduler scheduler = Application.instance.scheduler;
    scheduler.scheduleUpdateTarget(_setNewScene, 0.0, Timer.REPEAT_FOREVER, 0.0, !isRunning);
  }
  
  // UpdateTarget callback
  void _setNewScene(double dt) {
    Scheduler scheduler = Application.instance.scheduler;
    scheduler.unScheduleUpdateTarget(_setNewScene);
    
    // Before replacing, save the "send cleanup to scene"
    SceneManager sm = Application.instance.sceneManager;
    
    sendCleanupToScene = sm.sendCleanupToScene;
    sm.replaceScene(inScene);

    // TODO INPUT Enable events during transitions
    //Application.instance.enableInputEvents = true;
    
    outScene.visible = true;
  }
  
  @override
  void draw(DrawContext context) {
    if (inSceneOnTop) {
      outScene.visit(context);
      inScene.visit(context);
    }
    else {
      inScene.visit(context);
      outScene.visit(context);
    }
  }
  
  @override
  void onEnter() {
    super.onEnter();
    
    // TODO INPUT Disable events during transitions
    
    // outScene should not receive the onEnter callback
    // only the onExitTransitionDidStart
    outScene.onExitTransitionDidStart();

    inScene.onEnter();
  }
  
  @override
  void onExit() {
    super.onExit();

    // TODO INPUT Enable events during transitions

    outScene.onExit();

    // inScene should not receive the onEnter callback
    // only the onEnterTransitionDidFinish
    inScene.onEnterTransitionDidFinish();
  }

  @override
  void cleanup([bool cleanUp = true])
  {
    super.cleanup(cleanUp);

    if (sendCleanupToScene)
      outScene.cleanup(cleanUp);
  }

  void hideOutShowIn() {
    inScene.visible = true;
    outScene.visible = false;
  }
}