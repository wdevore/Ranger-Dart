part of unittests;

/**
 * Display a message that directs the user to touch an icon to access
 * a slideout panel. The panel is a Div with list items. Each item is
 * a series test.
 */
class GameLayer extends Ranger.BackgroundLayer {
  Ranger.SpriteImage _panelIcon;

  TestsDialog _testsPanel;
  GameScene gameScene;
  
  CanvasGradient _gradient;
  bool _expandPanelOnReturn = false;
  
  GameLayer();
 
  factory GameLayer.withColor(Ranger.Color4<int> backgroundColor, [bool centered = true, int width, int height]) {
    GameLayer layer = new GameLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = false;
    layer.color = backgroundColor;
    layer.showOriginAxis = false;
    return layer;
  }

  @override
  bool init([int width, int height]) {
    super.init(width, height);
    
    Ranger.Application app = Ranger.Application.instance;
    UTE.Tween.registerAccessor(Ranger.SpriteImage, app.animations);

    if (!GameManager.instance.isBaseResourcesReady) {
      GameManager.instance.baseInit().then((_) {
        _panelIcon = new Ranger.SpriteImage.withElement(GameManager.instance.resources.list, true);
        _testsPanel = new TestsDialog.withHideCallback(_doTest);
        _configure();
        _animateIn();
        _expandPanelOnReturn = false;
      });
    }
    
    return true;
  }
  
  @override
  void onEnter() {
    enableMouse = true;
    super.onEnter();

    if (_expandPanelOnReturn) {
      _placePanelIconOffScreen();
      _testsPanel.show();
      _expandPanelOnReturn = false;
    }
    else {
      _animateIn();
    }
  }

  _doTest(String title) {
    Ranger.Application app = Ranger.Application.instance;
    Ranger.TransitionScene transition;
    
    // Transition from the GameScene that is "hosting" this layer/dialog
    // a new scene. The new scene will begin a loop until the user
    // clicks the "return" icon in the upper-right corner.
    switch(title) {
      case "MoveIn Transitions":
        MoveInScene inComingScene = new MoveInScene();
        inComingScene.backgroundGradient(Ranger.color4IFromHex("#8d89a5"), Ranger.color4IFromHex("#5c4e63"));
        inComingScene.tag = 409;
        
        transition = new Ranger.TransitionMoveInFrom.initWithDurationAndScene(0.5, inComingScene, Ranger.TransitionMoveInFrom.FROM_LEFT);
        break;
      case "SlideIn Transitions":
        SlideInScene inComingScene = new SlideInScene();
        inComingScene.backgroundGradient(Ranger.color4IFromHex("#d22630"), Ranger.color4IFromHex("#e04e39"));
        inComingScene.tag = 610;
        
        transition = new Ranger.TransitionSlideIn.initWithDurationAndScene(0.5, inComingScene, Ranger.TransitionSlideIn.FROM_LEFT);
        break;
      case "Other Transitions":
        MiscTransitionsScene inComingScene = new MiscTransitionsScene();
        inComingScene.backgroundGradient(Ranger.color4IFromHex("#ffffff77"), Ranger.color4IFromHex("#fedd00cc"));
        inComingScene.tag = 1610;
        
        transition = new Ranger.TransitionSlideIn.initWithDurationAndScene(0.5, inComingScene, Ranger.TransitionSlideIn.FROM_LEFT);
        break;
      case "Transform Animations":
        TransformsScene inComingScene = new TransformsScene();
        inComingScene.backgroundGradient(Ranger.color4IFromHex("#ffaa77"), Ranger.color4IFromHex("#dd9922"));
        inComingScene.tag = 1610;
        
        transition = new Ranger.TransitionSlideIn.initWithDurationAndScene(0.5, inComingScene, Ranger.TransitionSlideIn.FROM_LEFT);
        break;
      case "Color Animations":
        ColorsScene inComingScene = new ColorsScene();
        inComingScene.backgroundGradient(Ranger.color4IFromHex("#253746"), Ranger.color4IFromHex("#ced9e5"));
        inComingScene.tag = 1610;
        
        transition = new Ranger.TransitionSlideIn.initWithDurationAndScene(0.5, inComingScene, Ranger.TransitionSlideIn.FROM_LEFT);
        break;
      case "Particle Systems 1":
        ParticleSystemsScene inComingScene = new ParticleSystemsScene();
        inComingScene.backgroundGradient(Ranger.color4IFromHex("#002855"), Ranger.color4IFromHex("#072b31"));
        inComingScene.tag = 1610;
        
        transition = new Ranger.TransitionSlideIn.initWithDurationAndScene(0.5, inComingScene, Ranger.TransitionSlideIn.FROM_LEFT);
        break;
      case "Particle Systems 2":
        ParticleSystems2Scene inComingScene = new ParticleSystems2Scene();
        inComingScene.backgroundGradient(Ranger.color4IFromHex("#41273b"), Ranger.color4IFromHex("#4b3d2a"));
        inComingScene.tag = 1610;
        
        transition = new Ranger.TransitionSlideIn.initWithDurationAndScene(0.5, inComingScene, Ranger.TransitionSlideIn.FROM_LEFT);
        break;
      case "Fonts":
        FontsScene inComingScene = new FontsScene();
        inComingScene.backgroundGradient(Ranger.color4IFromHex("#d0d3d4"), Ranger.color4IFromHex("#7c878e"));
        inComingScene.tag = 1610;
        
        transition = new Ranger.TransitionSlideIn.initWithDurationAndScene(0.5, inComingScene, Ranger.TransitionSlideIn.FROM_LEFT);
        break;
      case "Sprites":
        SpritesScene inComingScene = new SpritesScene();
        inComingScene.backgroundGradient(Ranger.color4IFromHex("#857874"), Ranger.color4IFromHex("#5e514d"));
        inComingScene.tag = 1610;
        
        transition = new Ranger.TransitionSlideIn.initWithDurationAndScene(0.5, inComingScene, Ranger.TransitionSlideIn.FROM_LEFT);
        break;
      case "Space Mappings":
        SpacesScene inComingScene = new SpacesScene();
        inComingScene.backgroundGradient(Ranger.color4IFromHex("#000000"), Ranger.color4IFromHex("#be84a3"));
        inComingScene.tag = 1610;
        
        transition = new Ranger.TransitionSlideIn.initWithDurationAndScene(0.5, inComingScene, Ranger.TransitionSlideIn.FROM_LEFT);
        break;
      case "Keyboard Input":
        KeyboardScene inComingScene = new KeyboardScene();
        inComingScene.backgroundGradient(
            Ranger.color4IFromHex("#d0bec7"), Ranger.color4IFromHex("#af95a6"));
        inComingScene.tag = 1610;
        
        transition = new Ranger.TransitionSlideIn.initWithDurationAndScene(0.5, inComingScene, Ranger.TransitionSlideIn.FROM_LEFT);
        break;
      case "Mouse Input":
        MouseScene inComingScene = new MouseScene();
        inComingScene.backgroundGradient(
            Ranger.color4IFromHex("#d0bec7"), Ranger.color4IFromHex("#af95a6"));
        inComingScene.tag = 1610;
        
        transition = new Ranger.TransitionSlideIn.initWithDurationAndScene(0.5, inComingScene, Ranger.TransitionSlideIn.FROM_LEFT);
        break;
      case "Touch Input":
        TouchScene inComingScene = new TouchScene();
        inComingScene.backgroundGradient(
            Ranger.color4IFromHex("#333333"), Ranger.color4IFromHex("#777777"));
        inComingScene.tag = 1610;
        
        transition = new Ranger.TransitionSlideIn.initWithDurationAndScene(0.5, inComingScene, Ranger.TransitionSlideIn.FROM_LEFT);
        break;
      default:
        _animateIn();
        break;
    }
    
    if (transition != null) {
      transition.tag = 9091;
      
      // This will push the current Scene (aka GameScene) and place
      // the transition Scene onto the stack.
      // When the transition completes the MainMoveInScene will be the
      // top Scene on the stack.
      app.sceneManager.pushScene(transition);
      _expandPanelOnReturn = true;
    }
    
  }
  
  void _animateIn() {
    Ranger.Application app = Ranger.Application.instance;
    
    double hHeight = app.designSize.height / 2.0;
    
    UTE.Timeline seq = new UTE.Timeline.sequence();
    seq.pushPause(0.25);
    
    UTE.Tween mTw1 = app.animations.moveTo(
        _panelIcon, 
        0.5,
        0.0, 0.0,
        UTE.Cubic.OUT, Ranger.TweenAnimation.TRANSLATE_Y, null, false);

    seq.push(mTw1);
    seq.start();
  }
  
  void _configure() {
    Ranger.Application app = Ranger.Application.instance;
    
    double hHeight = app.designSize.height / 2.0;

    //---------------------------------------------------------------
    // Create nodes.
    //---------------------------------------------------------------
    Ranger.TextNode desc = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    desc.text = "Touch icon below to access tests panel...";
    desc.shadows = true;
    desc.setPosition(-450.0, hHeight - (hHeight * 0.65));
    desc.uniformScale = 5.0;
    addChild(desc, 10, 445);

    addChild(_panelIcon, 10, 911);
    _panelIcon.uniformScale = 3.0;
    
    _placePanelIconOffScreen();
  }
 
  void _placePanelIconOffScreen() {
    Ranger.Application app = Ranger.Application.instance;
    
    double hHeight = app.designSize.height / 2.0;
    // Calc position so the icon is hiding just below the bottom scene edge.
    double yLoc = -hHeight - (_panelIcon.imageHeight * _panelIcon.uniformScale) / 2.0;
    _panelIcon.setPosition(0.0, yLoc);
  }
  
  @override
  bool onMouseDown(MouseEvent event) {
    if (_testsPanel.isShowing)
      return true;
    
    Ranger.Application app = Ranger.Application.instance;
    Ranger.Vector2P nodeP = app.drawContext.mapViewToNode(_panelIcon, event.offset.x, event.offset.y);
    nodeP.moveToPool();

    _panelIcon.rotationByDegrees = 0.0;
    
    if (_panelIcon.containsPoint(nodeP.v)) {
      // show access panel.
      _animateIconOut(app);
      _testsPanel.show();
    }
    
    return true;
  }
  
  void _animateIconOut(Ranger.Application app) {
    // Animate icon to wiggle
    double hHeight = app.designSize.height / 2.0;

    UTE.Timeline seq = new UTE.Timeline.sequence();
    
    UTE.Tween tw1 = app.animations.rotateTo(
        _panelIcon,
        0.15,
        -5.0,
        UTE.Cubic.OUT,
        null, false);

    seq.push(tw1);

    UTE.Tween tw2 = app.animations.rotateTo(
        _panelIcon,
        0.15,
        5.0,
        UTE.Cubic.OUT,
        null, false);

    seq.push(tw2);
    
    // Here we setup our own tween because we need to provide a callback.
    // The TweenAnimation class is for simple type fire and forget type
    // animations. But there are times when we need to know when the
    // the animation is complete as in this case.
    UTE.Tween tw3 = new UTE.Tween.to(_panelIcon, Ranger.TweenAnimation.ROTATE, 0.15)
      ..targetValues = [0.0]
      ..easing = UTE.Cubic.OUT
      ..callback = animateOutComplete
      ..callbackTriggers = UTE.TweenCallback.COMPLETE;
    UTE.TweenManager.setAutoStart(tw3, false);
    app.animations.add(tw3);
    
    seq.push(tw3);
    
    double yLoc = -hHeight - (_panelIcon.imageHeight * _panelIcon.uniformScale) / 2.0;
    
    UTE.Tween mTw1 = app.animations.moveTo(
        _panelIcon, 
        0.25,
        yLoc, 0.0,
        UTE.Cubic.IN, Ranger.TweenAnimation.TRANSLATE_Y, null, false);

    seq.push(mTw1);

    seq.start();
  }
  
  void animateOutComplete(int type, UTE.BaseTween source) {
    _panelIcon.rotationByDegrees = 0.0;
  }

  void drawBackground(Ranger.DrawContext context) {
    if (!transparentBackground) {
      CanvasRenderingContext2D context2D = context.renderContext as CanvasRenderingContext2D;

      Ranger.Size<double> size = contentSize;
      context.save();

      if (_gradient == null) {
        _gradient = context2D.createLinearGradient(0.0, 0.0, size.width, 0.0);
        _gradient.addColorStop(0.0, Ranger.color4IFromHex("#385e9d").toString());
        _gradient.addColorStop(1.0, Ranger.color4IFromHex("#7474c1").toString());
      }

      context2D..fillStyle = _gradient
          ..fillRect(0.0, 0.0, size.width, size.height);

      
      Ranger.Application.instance.objectsDrawn++;
      
      context.restore();
    }
  }

}
