part of ranger;

/**
 * The [SceneManager] manages [Scene]s. Some [Scene]s are transient
 * while others are permanent during the life of the game.
 * For example, the splash screen is transient. There is no reason to
 * keep the splash screen [Scene] when it is only seen once during the
 * life of the game.
 * 
 * The [SceneManager] is a "System" in and of itself. The [Core] calls the
 * [SceneManager.step] method passing the active [DrawContext].
 * [step] then visits the current running [Scene] where visibility
 * and rendering can occur.
 */
class SceneManager {
  static const int TO_ROOT = 0;
  static const int ALL = -1;
  
  // ----------------------------------------------------------
  // Properties
  // ----------------------------------------------------------
  ListQueue<BaseNode> _scenes = new ListQueue<BaseNode>();
  
  BaseNode runningScene;
  BaseNode _nextScene;
  
  bool ignoreClear = false;
  
  /**
   * Whether or not the replaced [Scene] will be cleaned up.
   * If the new [Scene] is pushed, then the old [Scene] won't be cleaned up.
   * If the new [Scene] replaces the old one, the old scene will be cleaned up.
   */
  bool sendCleanupToScene = false;
  
  // ----------------------------------------------------------
  // Constructors
  // ----------------------------------------------------------
  SceneManager();
  
  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  /// If there are no more [Scene]s to draw [step] returns false
  /// Indicating the app the core should begin shutting down.
  bool step(DrawContext context) {
    if (_scenes.isEmpty) {
      Logging.warning("SceneManager.step: no more scenes to visit.");
      return false;
    }
    
    // Clear.
    // If there is a Layer that fills the area then ignoreClear should 
    // set to true.
    if (!ignoreClear) {
      context.clear();
    }
    
    if (_nextScene != null)
      setNextScene();
    
    // Preprocess view prior to visiting Nodes.
    context.before();
    
    // TODO Comment out for RELEASE mode
    Application.instance.objectsDrawn = 0;
    
    // Visit the Scene's nodes.
    if (runningScene != null) {
      //print("SceneManager.step visiting ${runningScene.tag}");
      runningScene.visit(context);
      runningScene.completeVisit();
    }
    
    // Post process view after visiting Nodes.
    context.after();
    
    return true;  // continue to draw
  }
  
  void setNextScene() {
    // Capture currently running scene type.
    bool runningSceneIsTransition = runningScene is TransitionScene;

    if (!(_nextScene is TransitionScene)) {
      if (runningScene != null) {
        //print("SceneManager.setNextScene exits - ${runningScene.tag}");
        runningScene.onExitTransitionDidStart();
        runningScene.onExit();
      }
      
      if (sendCleanupToScene && runningScene != null) {
        //print("SceneManager.setNextScene ** cleanup ** - ${runningScene.tag}");
        runningScene.cleanup(sendCleanupToScene);
      }
    }
    
    runningScene = _nextScene;
    
    _nextScene = null;
    
    // Are we transitioning from one Scene to the next.
    if (!runningSceneIsTransition && runningScene != null) {
      //print("SceneManager.setNextScene enters - ${runningScene.tag}");
      runningScene.onEnter();
      runningScene.onEnterTransitionDidFinish();
    }
  }
  
  /**
   * Pop off a [Scene] from the queue.
   * This [Scene] will replace the running one.
   * The running [Scene] will be deleted. 
   * If there are no more [Scene]s in the stack the execution is terminated.
   * ONLY call it if there is a running scene.
   */
  void popScene() {
    if (runningScene == null) {
      Logging.error("popScene: There is no running scene.");
      return;
    }
    
    if (_scenes.isEmpty) {
      // No more Scenes to run.
      Logging.warning("popScene: There are no scenes to pop.");
    }
    else {
      // Allow running scene a chance to cleanup.
      sendCleanupToScene = true;
      
      BaseNode scene = _scenes.removeFirst();
      //print("SceneManager.popScene popped scene: ${scene}. Next scene is ${_scenes.first}");
      
      if (_scenes.isNotEmpty) {
        _nextScene = _scenes.first;
      }
    }
    //print("SceneManager.popScene " + this.toString());
  }
  
  /**
   * Suspends the execution of the running [Scene],
   * pushing it on the stack of suspended [Scene]s.
   * The new [scene] will be executed.
   */
  void pushScene(Node scene) {
    if (scene == null) {
      Logging.error("pushScene: Scene not supplied.");
      return;
    }

    sendCleanupToScene = false;

    //if (_scenes.length > 0)
    //  print("SceneManager.pushScene pushing scene: ${scene} above ${_scenes.first}");
    //else
    //  print("SceneManager.pushScene pushing ${scene} as first scene");
    
    _scenes.addFirst(scene);
    _nextScene = scene;
    //print("SceneManager.pushScene " + this.toString());
  }

  /**
   * Replaces the running [Scene] with a new one.
   * The running [Scene] is terminated. 
   * ONLY call it if there is a running [Scene].
   */
  void replaceScene(Node scene) {
    if (runningScene == null) {
      Logging.error("SceneManager.replaceScene: Use runWithScene instead to start the director");
    }
    
    if (scene == null) {
      Logging.error("SceneManager.replaceScene: scene should not be null");
      return;
    }

    if (_scenes.isEmpty) {
      //print("SceneManager.replaceScene adding ${scene} as first scene");
      _scenes.add(scene);
    } else {
      BaseNode firstScene = _scenes.removeFirst();
      //print("SceneManager.replaceScene replacing ${firstScene} with ${scene}");
      _scenes.addFirst(scene);
    }

    _nextScene = scene;
    sendCleanupToScene = true;
    //print("SceneManager.replaceScene " + this.toString());
  }
  
  /**
   * Pops off all [Scene]s from the queue until the root/bottom
   * [Scene] in the queue. 
   */
  void popToRootScene() {
    popToSceneStackLevel(TO_ROOT);
    //print("SceneManager.popToRootScene " + this.toString());
  }
  
  /**
   * Pops off all [Scene]s from the queue until it reaches [level].
   * The [level] is zero based. If there are 4 scenes then scene 4
   * is at [level] 3.
   *     levels:
   *     N   <--- Stack top, currently running scene
   *     ...
   *     3
   *     2
   *     1  
   *     0   <---- Root scene
   *     
   * If [level] is [ALL], it will effectively end/stop the [SceneManager].                                                 
   * If [level] is [TO_ROOT], it will pop all [Scene]s until it reaches to root [Scene].                    
   * If [level] is >= than stack top, nothing is done.
   */
  void popToSceneStackLevel(int level) {
    if (runningScene == null) {
      Logging.error("popToSceneStackLevel: No running scene.");
      return;
    }
    
    if (_scenes.isEmpty)
      return;
    
    int seaLevel = _scenes.length;
    
    if (level >= seaLevel - 1) {
      // Nothing to do. The level is already at the top.
      return;
    }
    
    int newStackTopLevel;
    
    if (level == ALL) {
      // Remove all scenes
      newStackTopLevel = 0;
      level = seaLevel;
    }
    else {
      newStackTopLevel = level + 1;
      level = seaLevel;
    }
    
    while (level > newStackTopLevel) {
      Scene current = _scenes.removeFirst();
      if (current.isRunning) {
        current.onExitTransitionDidStart();
        current.onExit();
      }
      current.cleanup();
      level--;
    }
    
    if (_scenes.isNotEmpty)
      _nextScene = _scenes.first;
    
    sendCleanupToScene = false;
    //print("SceneManager.popToSceneStackLevel " + this.toString());
  }
  
  /**
   * Pops off all [Scene]s from the queue until it reaches [tag].
   * Note: Tags are not sorted. This method simply removes scenes
   * off the top until it reaches [tag]. [tag] remains on the top of the
   * stack.
   */
 void popToSceneTag(int tag) {
    if (runningScene == null) {
      Logging.error("popToSceneTag: No running scene.");
      return;
    }
    
    if (_scenes.isEmpty)
      return;
    
    Scene scene = _scenes.first;
    
    while (scene.tag != tag) {
      Scene current = _scenes.removeFirst();
      
      if (current.isRunning) {
        current.onExitTransitionDidStart();
        current.onExit();
      }
      current.cleanup();
      
      scene = _scenes.first;
    }

    if (_scenes.isNotEmpty)
      _nextScene = _scenes.first;
    
    sendCleanupToScene = false;
    //print("SceneManager.popToSceneTag " + this.toString());
  }
  
  void end() {
    popToSceneStackLevel(ALL);
  }

  @override
  String toString() {
    StringBuffer sb = new StringBuffer();
    sb.write("Scene Stack: ");
    _scenes.forEach((Scene s) => sb.write(s.toString() + ","));
    return sb.toString();
  }
}