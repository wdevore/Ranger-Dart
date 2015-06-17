part of ranger;

class ORIENTATION {
  /// Device oriented vertically, home button on the bottom
  static const int PORTRAIT = 0;
  /// Device oriented vertically, home button on the top
  static const int PORTRAIT_UPSIDE_DOWN = 1;
  /// Device oriented horizontally, home button on the right
  static const int LANDSCAPE_LEFT = 2;
  /// Device oriented horizontally, home button on the left
  static const int LANDSCAPE_RIGHT = 3;
}

// From http://www.w3schools.com/jsref/prop_style_cursor.asp
class CURSOR_STYLE {
  static const String MOVE = "move";
  static const String CROSSHAIR = "crosshair";
  static const String DEFAULT = "default";
  static const String POINTER = "pointer";
  static const String TEXT = "text";
  static const String NOT_ALLOWED = "not-allowed";
  static const String NONE = "none";
  static const String HELP = "help";
  static const String COPY = "copy";
}

/*
 * If the container is specified with dimensions then Ranger will attempt
 * to fit it to the Window.
 * If the Window can't fit the dimensions then the container is resized
 * to the Window. The Window's dimensions are based off the inner values.
 * 
 * Design dimensions are virtual requirements. They are typically what
 * you code against. Sometimes the design can match the physical
 * dimensions and sometimes not.
 * The Design fits within the Canvas not the Container. The ratio of the
 * Canvas and Design produces a scaling factor applied to the context
 * AffineTransform thus insuring the Design fits within the Canvas.
 */

/**
 * Hints to influence how the surface/container is sized/fit
 * within the Window.
 */
class CONTAINER_FIT_HINT {
  /// The [Application] will fit Container to the Window with no borders
  /// or room for controls to fit. The controls will be off screen and
  /// require scrolling to see them.
  static const int MAX_WINDOW_EXTENTS = 0;
  
  /// The [Application] will attempt to match the Div's height but
  /// respect the Design's width.
  /// The controls will be off screen and require scrolling to see them.
  static const int MAX_WINDOW_HEIGHT_EXTENT = 1;
  
  /// The [Application] will attempt to match the Div's width, but will be
  /// restricted to the Window's width.
  static const int MAX_WINDOW_WIDTH_EXTENT = 2;
  
  /// The [Application] attempts to match Container's size with
  /// both the Div's width and height specifications.
  static const int MAX_WINDOW_BOTH_EXTENT = 3;

  /// The [Application] will do nothing. The Container will overflow out
  /// of the window. Resize browser to see all of the Container/Canvas.
  /// There is no scaling or skewing.
  static const int MAX_DESIGN_EXTENTS = 4;

  /// The [Application] will do nothing. The Container will be the size
  /// defined in the html.
  static const int CONTAINER_FIT = 5;
}

/**
 * How to align the Canvas with in the Container. No alignment is done
 * if [CONTAINER_FIT_HINT] is [MAX_EXTENTS].
 */
class CANVAS_ALIGNMENT_POLICY {
  /// Adjust canvas's top-left margins to align to center of container.
  static const int CENTER = 0;
  /// Canvas will gravitate to the upper-left of container.
  static const int NONE = 1;
  /// Canvas is floated left and centered vertically
  static const int LEFT = 2;
  /// Canvas is floated right and centered vertically. 
  static const int RIGHT = 3;
}

/**
 * How the Canvas fits to the container in relation to the Design
 * dimensions.
 * Ranger will always display the Design dimensions, but it could end up
 * being skewed. For example, if your design is 300x900 and the Canvas
 * ends up being 900x300.
 */
class CANVAS_FIT_POLICY {
  /// The Canvas will fill the container.
  /// Skewing may occur due to the Design dimensions not matching
  /// the container, hence the Canvas may appear stretched or compressed.
  static const int MAX_EXTENTS = 0;
  
  /// The Canvas is matched to the Design dimensions. However, the Design
  /// dimensions are still restricted to the Container.
  /// This produces no skewing, but it may leave borders if the Design
  /// doesn't fit fully in the Canvas.
  static const int DESIGN_EXTENTS = 1;

  /// The Design is synced with the Canvas of which the Canvas is extended
  /// to the Container.
  /// This produces no skewing because the Design matches the Canvas.
  /// However, you have no choice for the Design because it is made for
  /// you in order to sync to the Canvas.
  static const int CONTAINER_EXTENTS = 2;

  /// The Design to Container aspect ratio is used to scale the Canvas
  /// to the Container. The smaller ratio is used.
  /// There is no skewing, but borders could be present as a result of the
  /// scaling. Canvas alignment policy is also forced to [CENTER].
  static const int RATIO_EXTENTS = 3;
  
  /// The Design to Container aspect ratio is used to scale the Canvas
  /// to the Container. The smaller ratio is used.
  /// There is no skewing, but the Design dimensions are stretched to the
  /// Canvas extents. This produces scaling. 
  /// Borders could be present around the Canvas because the Canvas may
  /// not have perfectly fit into the Container.
  /// Canvas alignment policy is also forced to [CENTER].
  /// 
  /// An example:
  /// Your Design is 400x300 but the Canvas ended up at 600x450
  /// because of a smaller ratio being chosen leading to a view
  /// scaling of 1.5x1.5. So the design ratio was maintained but has
  /// been "scaled" to fill the Canvas resulting in magnification.
  /// This is good if you don't want skewing while maintaining the Design.
  static const int SCALE_EXTENTS = 4;

  /// The Design is disregarded. The DIV container is used instead.
  /// This is typically used by desktop apps that have a fixed [DIV]
  /// to hold the display.
  static const int CONTAINER_EXTACT = 5;
}

/**
 * [Application] is the main application that binds Ranger-Dart into
 * a conhesive unit. It handles booting the engine, constructing the
 * core components (including the [Core]), loading in to the [Browser],
 * Setting up a message system ([EventBus]), configuring drawing context,
 * and registering timing systems (aka [TweenAnimation].
 * 
 * Your game will interact with this class the most.
 */
class Application {
  // ----------------------------------------------------------
  // Properties
  // ----------------------------------------------------------
  static final Application _instance = new Application._internal();

  Browser browser;
  Html.Window window;

  /**
   * The main [Scheduler] for most timing situations.
   */
  Scheduler scheduler;
  
  /**
   * The main event bus for the application.
   * https://pub.dartlang.org/packages/event_bus
   */
  EventBus eventBus = new EventBus();
  
  /**
   * [TweenAnimation] is a custom TweenAccessor for working with Nodes.
   * [_buildSystems] adds the Accessor to the scheduler as an "external"
   * system.
   */
  TweenAnimation animations;
  
  Core _core;
  
  SceneManager sceneManager;
  
  DrawContext drawContext;
  
  Function _readyToBuild;
  Function _sceneReady;
  
  Html.DivElement _container;
  int _containerWidth;
  int _containerHeight;
  
  Html.CanvasElement canvas;
  /**
   * current render type of game engine
   */
  int renderContextType;

  // physical dimensions of the device browser or mobile.
  Size<int> screenSize = new Size<int>(0, 0);
  bool _fullScreenActivated = false;
  
  // view size = Canvas size.
  Size<int> viewSize = new Size<int>(0, 0);
  
  /// The viewPort in world-space. It is typically used by visibility
  /// check behaviors. It is configured on a zoomChanged event.
  MutableRectangle<double> viewPortWorldAABB = new MutableRectangle<double>.withP(0.0, 0.0, 0.0, 0.0);

  /// Specified in view-space (aka window-space)
  MutableRectangle<double> viewPortAABB = new MutableRectangle<double>.withP(0.0, 0.0, 0.0, 0.0);

  // design size is the virtual size you want to design against.
  // It could be the same size as the view, in which the design/view
  // ratio is 1x1. Most likely the design is something you chose to
  // code against for consistency. However, on other devices this
  // may cause scaling which can either work for or against you.
  Size<double> designSize = new Size<double>(0.0, 0.0);
  Size<double> originalDesignSize = new Size<double>(0.0, 0.0);
  
  MutableRectangle<double> viewPort = new MutableRectangle(0, 0, 0, 0);
  
  Point viewScaleFactor = new Point(1.0, 1.0);
  Size<int> _viewSizeInPixels = new Size<int>(0, 0);

  // TODO remember to remove all objectsDrawn++ occurances.
  // DEBUG
  int objectsDrawn = 0;
  // DEBUG END
  
  // Application visible for first time.
  int _resizeEventCount = 0;
  // Track first time focus is gained
  int _focusGainedCount = 0;
  
  String _surfaceName;
  int _designWidth;
  int _designHeight;
  int _canvasFitPolicy;
  int _containerHint;
  int _canvasAlignment;
  
  // This flag is for debugging only. When debugging, events are still
  // triggered. For example, a resize events occurs and is sent to the
  // callback even though the code has stopped. This happens when a
  // breakpoint is placed in the _pageShow method. The browser is still
  // "booting" up and displaying the window to which resize events are
  // being sent to the _windowResize method.
  // However, the Container and Canvas havn't be created yet and the code
  // starts hitting null objects.
  bool _pageShowDone = false;
  
  bool _loading = true;
  LinkedHashMap configuration;

  /**
   * BeforeUnload event.
   * Note: USE [beforeUnloadCallback] event to properly store game state prior to exiting.
   * 
   * DON'T use [unloadCallback] to store state on exit as Pubs are
   * silently "cutoff" from storing to local-storage.
   */ 
  Function beforeUnloadCallback;

  // Unload event
  Function unloadCallback;
  
  /**
   * This event occurs when moving between tabs in a browser. You can
   * use it to pause your game.
   */
  Function visibilityCallback;
  
  StreamSubscription _fullscreenSubscription;
  StreamSubscription _fullscreenExitSubscription;
 
  
  // ----------------------------------------------------------
  // Factories with different design layout and constraints.
  // ----------------------------------------------------------
  /**
   * [surfaceElement] should be "gameSurface", otherwise the Application
   * will issue an error.
   * [buildReady] is a callback that indicates that the Application has
   * finished initializing and it now time for your game to begin building/
   * configuring itself. In this callback you build your game by
   * creating [BaseNode]'s. And if needed you can also access accurate size,
   * context and drawing information.
   */
  factory Application(
      Html.Window window, 
      String surfaceElement,
      Function buildReady,
      [
       int designWidth = 600, 
       int designHeight = 338, 
       int containerHint = CONTAINER_FIT_HINT.MAX_WINDOW_BOTH_EXTENT,
       int canvasFitPolicy = CANVAS_FIT_POLICY.SCALE_EXTENTS, 
       int canvasAlignment = CANVAS_ALIGNMENT_POLICY.CENTER
      ]) {
    _instance._readyToBuild = buildReady;

    _instance.window = window;
    
    _instance._surfaceName = surfaceElement;
    _instance._designWidth = designWidth;
    _instance._designHeight = designHeight;
    _instance._canvasFitPolicy = canvasFitPolicy;
    _instance._containerHint = containerHint;
    _instance._canvasAlignment = canvasAlignment;
    
    _instance._configureStates();
    _instance._buildSystems();
    
    _instance._beginBoot();
    
    return _instance;
  }

  /**
   * Use this factory if you need Ranger to fit within a container
   * without any scaling. Typically used for desktop applications that
   * want to "host" Ranger in a window area.
   */
  factory Application.fitDesignToContainer(
      Html.Window window, 
      String surfaceElement,
      Function buildReady,
      Function sceneReady,
      [
       int designWidth = 600, 
       int designHeight = 338
      ]) {
    _instance._readyToBuild = buildReady;
    _instance._sceneReady = sceneReady;
    _instance.window = window;
    
    _instance._surfaceName = surfaceElement;
    _instance._designWidth = designWidth;
    _instance._designHeight = designHeight;
    _instance._canvasFitPolicy = CANVAS_FIT_POLICY.CONTAINER_EXTACT;
    _instance._containerHint = CONTAINER_FIT_HINT.CONTAINER_FIT;
    _instance._canvasAlignment = CANVAS_ALIGNMENT_POLICY.NONE;
    
    // Finish boot sequence.
    _instance._buildSystems();
    
    _instance._beginBoot();

    return _instance;
  }

  factory Application.fitDesignToCanvasCentered(
      Html.Window window, 
      String surfaceElement,
      Function buildReady,
      [
       int designWidth = 600, 
       int designHeight = 338
      ]) {
    _instance._readyToBuild = buildReady;

    _instance.window = window;
    
    _instance._surfaceName = surfaceElement;
    _instance._designWidth = designWidth;
    _instance._designHeight = designHeight;
    _instance._canvasFitPolicy = CANVAS_FIT_POLICY.SCALE_EXTENTS;
    _instance._containerHint = CONTAINER_FIT_HINT.MAX_WINDOW_BOTH_EXTENT;
    _instance._canvasAlignment = CANVAS_ALIGNMENT_POLICY.CENTER;
    
    // Finish boot sequence.
    _instance._buildSystems();
    
    _instance._beginBoot();

    return _instance;
  }

  /**
   * This factory is on desktops and mobiles. If on a desktop then the
   * game surface DIV is used as the simulated physical device dimensions.
   */
  factory Application.fitDesignToWindow(
      Html.Window window, 
      String surfaceElement,
      Function buildReady,
      [
       int designWidth = 600, 
       int designHeight = 338
      ]) {
    _instance._readyToBuild = buildReady;

    _instance.window = window;
    
    _instance._surfaceName = surfaceElement;
    _instance._designWidth = designWidth;
    _instance._designHeight = designHeight;
    _instance._canvasFitPolicy = CANVAS_FIT_POLICY.SCALE_EXTENTS;
    _instance._containerHint = CONTAINER_FIT_HINT.MAX_WINDOW_WIDTH_EXTENT;
    _instance._canvasAlignment = CANVAS_ALIGNMENT_POLICY.CENTER;
    
    // Finish boot sequence.
    _instance._buildSystems();
    
    _instance._beginBoot();

    return _instance;
  }

  Application._internal();
  
  // ----------------------------------------------------------
  // Instance
  // ----------------------------------------------------------
  static Application get instance => _instance;

  bool get upsEnabled => _core.enabledUPS;
  
  void _configureStates() {
    Html.HttpRequest.getString(CONFIG.CONFIG_OVERRIDE_FILE)
      .then(_processConfig)
      .catchError(_handleConfigError);
  }

  // This is an async method.
  void _processConfig(String jsonString) {
    configuration = JSON.decode(jsonString);
    
//    if (configuration.containsKey("DebugLevel"))
//      CONFIG.debug_level = configuration["DebugLevel"] as int;
//      
//    if (configuration.containsKey("Box2DEnabled"))
//      CONFIG.box2d = configuration["Box2DEnabled"] as bool;
//    
//    if (configuration.containsKey("Framerate"))
//      CONFIG.frameRate = configuration["Framerate"] as int;
//    
//    if (configuration.containsKey("RenderContext")) {
//      String s = configuration["RenderContext"] as String;
//      if (s == "RENDERMODE_CANVAS_ONLY")
//        CONFIG.renderMode = CONFIG.RENDERMODE_CANVAS_ONLY;
//      else if (s == "RENDERMODE_DEFAULT")
//        CONFIG.renderMode = CONFIG.RENDERMODE_DEFAULT;
//      else if (s == "RENDERMODE_WEBGL_ONLY")
//        CONFIG.renderMode = CONFIG.RENDERMODE_WEBGL_ONLY;
//    }
//
//    if (configuration.containsKey("SurfaceTag"))
//      CONFIG.surfaceTag = configuration["SurfaceTag"] as String;
//
//    if (configuration.containsKey("BaseCoordSystem")) {
//      CONFIG.base_coordinate_system = configuration["BaseCoordSystem"] as bool;
//      Logging.info("Application._processConfig: base_coordinate_system is: ${CONFIG.base_coordinate_system}");
//    }
  }

  void _handleConfigError(Error error) {
    Logging.error("Application._handleConfigError: $error");
    Logging.error("Application._handleConfigError: Application aborted.");
  }
  
  void _buildSystems() {
    // We configure a context here even though we don't have any sizing
    // information yet. This allows Nodes to bind their rendering 
    // functions prior to running the core.
    // The actual sizing will occur when the Core starts from a
    // page-show event.
    _configureContext();

    browser = new Browser();
    browser.detect(window.navigator);
    
    sceneManager = new SceneManager();
    scheduler = new Scheduler();
    
    animations = new TweenAnimation();
    animations.priority = Scheduler.SYSTEM_HIGH_PRIORITY;
    scheduler.scheduleTimingTarget(animations);
  }
  
  void _beginBoot() {
    Logging.info("Booting application...");
    
    // Page-show event is emitted before Resize. It is emitted once when
    // the page is first shown. After that you get visibility events.
    Html.window.onPageShow.listen(
        (Html.Event e) => _pageShow(e)
        );
    
    // We want to listen for a resize event.
    // TODO Test on mobile device. We may not get a resize event and as
    // such the Core may never start!!!! Dartium does some funky things
    // that cause a resize event.
    // We may need to trigger off of something like focus or visibility.
    // you get focus/blur events when tab visibility changes.
    Html.window.onResize.listen(
        (Html.Event e) => _windowResize(e)
        );
  }
  
  void constructSurface() {
    //Logging.info("Constructing surface...");
    _configureSurface();

    _resizeRenderContext();

    _core = new Core(sceneManager, scheduler, drawContext, window);

    _registerEvents();
  }
  
  // This is called by any Node that wishes to signal the application
  // that it has setup up the scene.
  void sceneIsReady() {
    if (_sceneReady != null)
      _sceneReady();
  }
  
  /**
   * You must call [gameConfigured] AFTER you have built your [BaseNode]'s.
   */
  void gameConfigured() {
    _core.start();
  }
  
  void switchToFullscreen() {
    // Dart issue #21360
    _fullScreenActivated = !_fullScreenActivated;
    if (_fullScreenActivated) {
      _fullscreenSubscription = container.onFullscreenChange.listen((Html.Event e) {
        Html.DivElement divContainer = e.currentTarget as Html.DivElement;
        Logging.info("Application FullScreen Change: client=${divContainer.client}");
      });
      _fullscreenExitSubscription = container.onFullscreenError.listen((Html.Event e) {
        Logging.error("FullScreen Error: ${e.currentTarget}");
      });
      container.requestFullscreen();
    }
    else {
      Logging.info("Application Exiting fullscreen.");
      Html.HtmlDocument doc = window.document as Html.HtmlDocument;
      doc.exitFullscreen();
      _fullscreenSubscription.cancel();
      _fullscreenExitSubscription.cancel();
    }
  }
  
  // ----------------------------------------------------------
  // Sizes
  // ----------------------------------------------------------
  Size<int> get viewSizeInPixels {
    _viewSizeInPixels.set(
        (viewSize.width * viewScaleFactor.x).toInt(),
        (viewSize.height * viewScaleFactor.y).toInt());
    return _viewSizeInPixels;
  }
  
  // ----------------------------------------------------------
  // Events
  // ----------------------------------------------------------
  void _registerEvents() {
    // TODO Use visibility to pause Engine
    // This event triggers when moving between tabs.
    Html.document.onVisibilityChange.listen((Html.Event e) {
        if (visibilityCallback != null)
          visibilityCallback();
        else
          Logging.info("Visibility event unhandled.");
    });

    window.onUnload.listen((Html.Event e) {
      if (unloadCallback != null)
        unloadCallback();
    });

    window.onBeforeUnload.listen((Html.Event e) {
      if (beforeUnloadCallback != null)
        beforeUnloadCallback();
    });

    // This event is received when the browser "gains" focus not when it is
    // lost.
    Html.window.onFocus.listen(
        (Html.Event e) => _focusGained()
        );
    
    // This event is received when the browser "loses" focus not when it is
    // gained.
    //Html.window.onBlur.listen(
    //    (Html.Event e) => Logging.info("blur changed")
    //    );

}
  
  void _focusGained() {
    //Logging.info("_focusGained $_focusGainedCount");
    _focusGainedCount++;
  }
  
  // ----------------------------------------------------------
  // Window
  // ----------------------------------------------------------
  void shutdown() {
    scheduler.unScheduleTimingTarget(animations);

    _core.shutdown();
  }
  
  // ----------------------------------------------------------
  // Context
  // ----------------------------------------------------------
  void _configureContext() {
    // TODO WebGL update to detect chrome on Android 4.4x. It supports WebGL.
    if (CONFIG.renderMode == CONFIG.RENDERMODE_CANVAS_ONLY ||
        CONFIG.renderMode == CONFIG.RENDERMODE_DEFAULT &&
        browser.isMobile) {
      // Canvas was requested or defaulted.
      renderContextType = RENDER_TYPE.CANVAS;
    }
    else {
      renderContextType = RENDER_TYPE.WEBGL;
    }
    
    if (renderContextType == RENDER_TYPE.CANVAS)
      drawContext = new DrawCanvas(CONFIG.base_coordinate_system);
    else {
      drawContext = new DrawWebGL(canvas);
      if (drawContext == null) {
        Logging.warning("_configureView: failed to create WebGL view. Falling back to Canvas view.");
        drawContext = new DrawCanvas(CONFIG.base_coordinate_system);
        renderContextType = RENDER_TYPE.CANVAS;
      }
    }
  }
  
  bool get isCanvasContext => renderContextType == RENDER_TYPE.CANVAS;
  bool get isWebGLContext => renderContextType == RENDER_TYPE.WEBGL;

  int get framesPerPeriod => _core._framesPerPeriod;
  set framesPerPeriod(int v) => _core._framesPerPeriod = v;
  int get updatesPerPeriod => _core._updatesPerPeriod;
  set updatesPerPeriod(int v) => _core._updatesPerPeriod = v;
  
  int get frameCount => _core.frameCount;
  
  bool get updateStats => _core.deltaAccum >= CONFIG.DIRECTOR_FPS_INTERVAL;
  set deltaAccum(double v) => _core.deltaAccum = v;
  double get deltaAccum => _core.deltaAccum;
  double get fpsAverage => _core.fpsAverage;
  
  bool get stepEnabled => _core.stepEnabled;
  set stepEnabled(bool v) => _core.stepEnabled = v;
  
  set step(_) => _core.step(_core._frame_step);
  
  // ----------------------------------------------------------
  // Surface
  // ----------------------------------------------------------
  /**
   * Sets up main Canvas and Container Div.  
   * A Div that has no attributes will internally default to 350x150
   * If attributes are supplied and they are greater than the default
   * then those are used.
   * However, if the attribute dimensions are larger than the window size
   * they are resized to the inner window.
   * Declare a Div in your main html file:
   *     <Div id="gameSurface" width="800" height="450"></Div>
   * 
   * The attributes specified are merely Physical Dimensions (PD) of the
   * element. They don't specify Design Dimensions (DD).
   * For exammple, if PD is 500x300 and the requested DD is 1000x600 then
   * a scale 0.5x0.5 is needed to map points to pixels. A point at
   * 200x300 is actually at 100x150 in PD space.
   */
  void _configureSurface() {
    //Logging.info("_configureSurface");
    if (surface == null) {
      throw new Exception("Surface DIV element appears to be missing.");
    }

    Html.HtmlElement helement = surface;

    // Screen size is the window container's inner dimensions.
    screenSize.width = window.innerWidth;
    screenSize.height = window.innerHeight;

    if (helement.tagName == "CANVAS") {
      // --------------------------------------------------------------
      // Canvas element is given as the surface.
      // --------------------------------------------------------------
      Logging.error("Canvas surface not expected. Please use:");
      Logging.error(r"<Div id='gameSurface' width='800' height='450'></Div>");
      return;
      
    }
    else {
      // --------------------------------------------------------------
      // Div element is given as the surface.
      // --------------------------------------------------------------
      if (helement.tagName != "DIV") {
        Logging.error("Warning: target element is not a DIV. Please use:");
        Logging.error(r"<Div id='gameSurface' width='???' height='???'></Div>");
        Logging.error("or");
        Logging.error(r"<Div id='gameSurface'></Div>");
        return;
      }

      _container = helement;

      // We need configureContainer and configureViewSize for
      // pageShow event.
      _configureContainer();
      
      _configureViewSize();

      _configureCanvas();

      _alignCanvas();
    }

    //Logging.info("---- Application._configureSurface stats ----");
    //Logging.info("Screen size {${screenSize.width} x ${screenSize.height}}");
    //Logging.info("View size {${viewSize.width} x ${viewSize.height}}");
    //Logging.info("Container client {${_container.clientWidth} x ${_container.clientHeight}}");
    //Logging.info("Canvas size is {${canvas.width} x ${canvas.height}}");
    //Logging.info("Canvas client {${canvas.clientWidth} x ${canvas.clientHeight}}");

    // Calculate Design/View scaling ratio.
    _configureViewScale();
  }

  Html.HtmlElement get surface {
    Html.HtmlElement helement = Html.querySelector(_surfaceName);
    if (helement == null)
      helement = Html.querySelector('#' + _surfaceName);
    return helement;
  }
  
  Html.HtmlElement get container => _container;
  
  void _configureCanvas() {
    canvas = new Html.CanvasElement(width: viewSize.width, height: viewSize.height);
    canvas.id = "gameCanvas";
    canvas.style.zIndex = "2";

    drawContext.canvas = canvas;
    
    Html.Node parent = _container.parentNode;
    _container.append(canvas);
  }
  
  void _alignCanvas() {
    if (_container == null)
      return;
    
    if (_canvasFitPolicy != CANVAS_FIT_POLICY.MAX_EXTENTS) {
      switch (_canvasAlignment) {
        case CANVAS_ALIGNMENT_POLICY.CENTER:
          int offsetX = (_container.clientWidth - viewSize.width).abs() ~/ 2;
          canvas.style.marginLeft = offsetX.toString() + "px";

          int offsetY = (_container.clientHeight - viewSize.height).abs() ~/ 2;
          canvas.style.marginTop = offsetY.toString() + "px";
          break;
        case CANVAS_ALIGNMENT_POLICY.LEFT:
          int offsetY = (_container.clientHeight - viewSize.height).abs() ~/ 2;
          canvas.style.marginTop = offsetY.toString() + "px";
          break;
        case CANVAS_ALIGNMENT_POLICY.RIGHT:
          int offsetX = (_container.clientWidth - viewSize.width).abs();
          canvas.style.marginLeft = offsetX.toString() + "px";
          
          int offsetY = (_container.clientHeight - viewSize.height).abs() ~/ 2;
          canvas.style.marginTop = offsetY.toString() + "px";
          break;
        default:
          break;
      }
    }
  }
  
  void _configureViewSize() {
    if (_container == null)
      return;
    
    switch (_canvasFitPolicy) {
      case CANVAS_FIT_POLICY.MAX_EXTENTS:
        // Fit the Canvas into the Container regardless of the Design size.
        viewSize.width = _container.clientWidth;
        viewSize.height = _container.clientHeight;
        break;
      case CANVAS_FIT_POLICY.DESIGN_EXTENTS:
        if (_designWidth > _container.clientWidth)
          _designWidth = _container.clientWidth;
        if (_designHeight > _container.clientHeight)
          _designHeight = _container.clientHeight;
        viewSize.width = _designWidth;
        viewSize.height = _designHeight;
        break;
      case CANVAS_FIT_POLICY.CONTAINER_EXTENTS:
        viewSize.width = _designWidth = _container.clientWidth;
        viewSize.height = _designHeight = _container.clientHeight;
        break;
      case CANVAS_FIT_POLICY.RATIO_EXTENTS:
        // We want to scale the viewSize to match the aspect ratio of
        // the Design all while keeping the viewSize within the
        // Container.
        // So we want to scale the Design without exceeding the Container.
        double ratioCtDW = _container.clientWidth / _designWidth;
        double ratioCtDH = _container.clientHeight / _designHeight;
        
        // Thus we choose the smaller ratio to scale the Design
        double minRatio = math.min(ratioCtDW, ratioCtDH);
        
        viewSize.width = _designWidth = (_designWidth * minRatio).toInt();
        viewSize.height = _designHeight = (_designHeight * minRatio).toInt();
        // And force centering.
        _canvasAlignment = CANVAS_ALIGNMENT_POLICY.CENTER;
        break;
      case CANVAS_FIT_POLICY.SCALE_EXTENTS:
        // We want to scale the viewSize to match the aspect ratio of
        // the Design all while keeping the viewSize within the
        // Container.
        // However, we want to keep the original design scale.
        double ratioCtDW = _container.clientWidth / _designWidth;
        double ratioCtDH = _container.clientHeight / _designHeight;
        
        // Thus we choose the smaller ratio to scale the Design
        double minRatio = math.min(ratioCtDW, ratioCtDH);
        //Logging.info("_configureViewSize: minRatio: $minRatio");
        
        viewSize.width = (_designWidth * minRatio).toInt();
        viewSize.height = (_designHeight * minRatio).toInt();
        // And force centering.
        _canvasAlignment = CANVAS_ALIGNMENT_POLICY.CENTER;
        break;
      case CANVAS_FIT_POLICY.CONTAINER_EXTACT:
        viewSize.width = _containerWidth;
        viewSize.height = _containerHeight;
        break;
      default:
        break;
    }
    
    // Configure viewport rectangle in view-space
    //double shrinkBy = 1.0; // Mostly used for debugging.
    viewPortAABB.left = 0.0;//viewSize.width / shrinkBy;
    viewPortAABB.bottom = 0.0;//viewSize.height / shrinkBy;
    //double top = viewSize.height - (viewSize.height / shrinkBy);
    //double right = viewSize.width - (viewSize.width / shrinkBy);
    viewPortAABB.width = viewSize.width.toDouble();//(right - viewSize.width).abs();
    viewPortAABB.height = viewSize.height.toDouble();//(top - viewSize.height).abs();
    //print("Application._configureViewSize: viewport view-space:\n$viewPortAABB");

  }
  
  void _configureContainer() {
    // TODO _configureContainer, need to fix the container from
    // collapsing to far.
    //Logging.info("---- Application._configureContainer ----");
    //Logging.info("Inner window {${window.innerWidth} x ${window.innerHeight}}");
    //Logging.info("Outer window {${window.outerWidth} x ${window.outerHeight}}");
    //Logging.info("Page offsets {${window.pageXOffset} x ${window.pageYOffset}}");
    //Logging.info("Screen {${window.screen.width} x ${window.screen.height}}");
    //Logging.info("Screen top ${window.screenLeft} x ${window.screenTop}");
    
    //int widthDressing = window.outerWidth - window.innerWidth;
    //int heightDressing = window.outerHeight - window.innerHeight;
    //Logging.info("Window dressing {${widthDressing} x ${heightDressing}}");

    // A standard 1080p HDTV is 1920x1080 = 16x9 = aspect ratio of 1.8.
    // Nexus 7 = 1280x800 = 1.6 aspect ratio.
    // So I default to a reasonable desktop size that will allow about
    // 85% visible. This leaves room on my desktop for the editor.
    _containerWidth = 720;
    _containerHeight = 700;

    if (_container == null)
      return;
    
    // On a resize these attributes don't exist because we removed them.
    if (_container.attributes["width"] != null)
      _containerWidth = int.parse(_container.attributes["width"]);
    else {
      String w = _container.style.width;
      _containerWidth = int.parse(w.substring(0, w.indexOf("px")));
    }
    
    if (_container.attributes["height"] != null)
      _containerHeight = int.parse(_container.attributes["height"]);
    else {
      String h = _container.style.height;
      _containerHeight = int.parse(h.substring(0, h.indexOf("px")));
    }
    
    switch (_containerHint) {
      case CONTAINER_FIT_HINT.MAX_WINDOW_EXTENTS:
        // Ignore the Div's dimensions and fill the Window instead.
        _containerHeight = window.innerHeight;
        _containerWidth = window.innerWidth;
        break;
      case CONTAINER_FIT_HINT.MAX_WINDOW_HEIGHT_EXTENT:
        // Override the Div's height and fill the vertical window space.
        // Use the Div's width, but truncate if larger than window.
        _containerHeight = window.innerHeight;

        if (_containerWidth > window.innerWidth)
          _containerWidth = window.innerWidth;
        break;
      case CONTAINER_FIT_HINT.MAX_WINDOW_WIDTH_EXTENT:
        // Override the Div's width and fill the horizontal window space.
        // Use the Div's height, but truncate if larger than window.
        _containerWidth = window.innerWidth;
        
        if (_containerHeight > window.innerHeight)
          _containerHeight = window.innerHeight;
        break;
      case CONTAINER_FIT_HINT.MAX_DESIGN_EXTENTS:
        _containerWidth = _designWidth;
        _containerHeight = _designHeight;
        break;
      case CONTAINER_FIT_HINT.MAX_WINDOW_BOTH_EXTENT:
        // Use Div's attributes unless they are larger than the window.
        if (_containerWidth > window.innerWidth) {
          _containerWidth = window.innerWidth;
        }

        if (_containerHeight > window.innerHeight) {
          _containerHeight = window.innerHeight;
        }
        break;
      case CONTAINER_FIT_HINT.CONTAINER_FIT:
        break;
    }

    _container.style.width = _containerWidth.toString() + "px";
    _container.style.height = _containerHeight.toString() + "px";

    //Logging.info("Container attributes {${width} x ${height}}, Aspect: ${(width/height).toStringAsFixed(1)}");
    
    // Remove the attributes, we don't need them anymore.
    _container.attributes.remove("width");
    _container.attributes.remove("height");
    
    // A default color to help visually see boundary of container/surface.
    _container.style.backgroundColor = "#fce5cd";// peach/skin like color.

    _container.id = "gameSurface";
    _container.style.zIndex = "1";
    
    // Use CSS instead
    //_container.style.margin = "0 auto";
    //_container.style.position = 'relative';
    //_container.style.overflow = 'hidden';
    
    _container.style.minWidth = _containerWidth.toString() + "px";
    _container.style.minHeight = _containerHeight.toString() + "px";
  }

  /**
   * Design dimension (DD) is the requested size, doesn't matter if the device can
   * display it. This means DD will be "virtual" if it doesn't fit.
   * The goal is to always "fit" the DD to the Physical dimensions (PD) of
   * the Canvas which means scaling may be required.
   * 
   * You have two concepts to control:
   *  1) How the Canvas occupies its container
   *  2) Design/View scale ratio
   *  
   * [width] and [height] are the design dimensions that control the
   * scaling ratio on the context.
   */
  void _configureViewScale() {
    designSize.width = originalDesignSize.width = _designWidth.toDouble();
    designSize.height = originalDesignSize.height = _designHeight.toDouble();
    
    viewScaleFactor.x = viewSize.width / designSize.width;
    viewScaleFactor.y = viewSize.height / designSize.height;
    
    // calculate the resultant viewport
    double viewPortW = designSize.width * viewScaleFactor.x;
    double viewPortH = designSize.height * viewScaleFactor.y;

    viewPort.left = (viewSize.width - viewPortW) / 2.0;
    viewPort.bottom = (viewSize.height - viewPortH) / 2.0;
    viewPort.width = viewPortW;
    viewPort.height = viewPortH;
    
    //Logging.info("-------- Application._configureViewScale stats ---------");
    //Logging.info("designSize {${designSize}}");
    //Logging.info("viewScaleFactor {${viewScaleFactor}}");
    //Logging.info("viewPort {${viewPort}}");
  }
  
  void _pageShow(Html.Event e) {
    // On page-show the Dartium/Chromium window is still showing the
    // Chromium icon and text:
    // Google api...
    // For quick access...
    // Thus the dimensions will be smaller before the resize event.
    // 
    // If a tab is shown then there is no icon and text and the size is
    // accurate. In this case we can rely on the size information and
    // thus simulate a resize event.
    //Logging.info("_pageShow {${window.innerWidth} x ${window.innerHeight}}");
    
    constructSurface();
    _readyToBuild();
    
    _pageShowDone = true;
  }
  
  /*
   * The first resize event we get in the Dartium browser occurs after
   * the message html has been removed from the Window.
   * At this time the Window dimensions are "true".
   * 
   * All events after that are for resizing the Container, Canvas and
   * Context.
   */
  void _windowResize(Html.Event e) {
    if (!_pageShowDone) {
      Logging.info("Page showing not done.");
      return;
    }
    
    _resizeEventCount++;

    _resize();
  }
  
  void _resize() {
    // Screen size is the window container's inner dimensions.
    screenSize.width = window.innerWidth;
    screenSize.height = window.innerHeight;

    _configureContainer();

    _configureViewSize();

    _alignCanvas();

    // Calculate Design/View scaling ratio.
    _configureViewScale();
    
    canvas.width = viewSize.width;
    canvas.height = viewSize.height;

    _resizeRenderContext();
    
    //print("Application._resize canvas: (${canvas.clientLeft}, ${canvas.clientTop}) [${canvas.width} x ${canvas.height}]");
  }
  
  void _resizeRenderContext() {
    drawContext.scale.x = viewScaleFactor.x;
    drawContext.scale.y = viewScaleFactor.y;
    // We need to use Design dimensions because the Canvas context has
    // a transform set to the Design size.
    drawContext.size(designSize.width.toInt(), designSize.height.toInt());
  }
  
}

/*
//       There is a Canvas element present, wrap it with a Div.
//      canvas = helement;
//
//      viewSize.width = canvas.width;
//      viewSize.height = canvas.height;
//      
//      // Adjust width
//      if (viewSize.width > screenSize.width) {
//        viewSize.width = screenSize.width;
//      }
//      if (viewSize.width < 350) {
//        viewSize.width = 350;
//      }
//      
//      // Adjust height
//      if (viewSize.height > screenSize.height) {
//        viewSize.height = screenSize.height;
//      }
//      if (viewSize.height < 150) {
//        viewSize.height = 150;
//      }
//
//      _container = new Html.DivElement();      
//      
//      canvas.width = viewSize.width;
//      canvas.height = viewSize.height;
//      
//      // The container always tries to fill 100% of it area.
//      _container.style.width = "100%";
//      _container.style.height = "100%";
//      
//      Html.Node parent = canvas.parentNode;
//      parent.insertBefore(_container, canvas);
//      _container.append(canvas);
//
//      int offsetX = (_container.clientWidth - viewSize.width).abs() ~/ 2;
//      canvas.style.marginLeft = offsetX.toString() + "px";
//
//      int offsetY = (_container.clientHeight - viewSize.height).abs() ~/ 2;
//      canvas.style.marginTop = offsetY.toString() + "px";


*/