part of template2;

/**
 * A simple layer that demonstrates async loading of several images
 * while displaying a spinner overlay.
 * 
 * In a real production app you would want to create a resource loading
 * framework that uses the concepts of this example.
 */
class GameLayer extends Ranger.BackgroundLayer {
  static int _nextTag = 100000;
  
  int _grinTag;
  int _fireTag;
  int _giftTag;
  int _evilTag;
  int _rocketTag;
  
  Ranger.OverlayLayer _loadingOverlay;
  Ranger.SpriteImage _overlaySpinner;

  int _loadingCount = 0;
  bool _loaded = false;

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
    if (super.init(width, height)) {
      Ranger.Application app = Ranger.Application.instance;

      // We need to register the SpriteImage class so that the
      // Universal Tween Engine (UTE) recognizes the class.
      UTE.Tween.registerAccessor(Ranger.SpriteImage, app.animations);
    }
    
    return true;
  }
  
  @override
  void onEnterTransitionDidFinish() {
    super.onEnterTransitionDidFinish();
    _configure();
  }

  void _loadingUpdate(int tag) {
    if (tag == _grinTag) {
      Ranger.SpriteImage si = getChildByTag(_grinTag);
      si.uniformScale = 2.0;
    }
    else if (tag == _fireTag) {
      Ranger.SpriteImage si = getChildByTag(_fireTag);
      si.uniformScale = 3.0;
    }
    else {
      Ranger.SpriteImage si = getChildByTag(tag);
      si.uniformScale = 5.0;
    }
    
    // Have all the assets loaded.
    if (_loadingCount == 0) {
      Ranger.Application app = Ranger.Application.instance;
      // Stop any previous animations; especially infinite ones.
      app.animations.flush(_overlaySpinner);
      
      // All sprites have loaded. Remove overlay.
      // I specify "true" because this Layer Node isn't needed ever again.
      //              ^--------------v
      removeChild(_loadingOverlay, true);
      _loaded = true;
    }
  }

  void _configure() {
    //---------------------------------------------------------------
    // Text node
    //---------------------------------------------------------------
    Ranger.TextNode desc = new Ranger.TextNode.initWith(Ranger.Color4IDartBlue);
    desc.text = "Ranger GameLayer Template 2";
    desc.shadows = true;
    desc.setPosition(-570.0, 200.0);
    desc.uniformScale = 8.0;
    addChild(desc, 10, 445);

    //---------------------------------------------------------------
    // Loading-overlay
    //---------------------------------------------------------------
    Ranger.Color4<int> darkBlue = new Ranger.Color4<int>.withRGBA(109~/3, 157~/3, 235~/3, 128);
    _loadingOverlay = new Ranger.OverlayLayer.withColor(darkBlue);
    _loadingOverlay.transparentBackground = false;
    addChild(_loadingOverlay, 20, 555);
    
    Ranger.TextNode loading = new Ranger.TextNode.initWith(Ranger.Color4IOrange);
    loading.text = "Loading...";
    loading.shadows = true;
    loading.setPosition(-150.0, -300.0);
    loading.uniformScale = 8.0;
    _loadingOverlay.addChild(loading, 10, 556);

    Resources resources = GameManager.instance.resources;
    
    Ranger.Application app = Ranger.Application.instance;
    _overlaySpinner = resources.getSpinnerRing(1.5, -360.0, 7001);
    // Track this infinite animation.
    app.animations.track(_overlaySpinner, Ranger.TweenAnimation.ROTATE);

    _loadingOverlay.addChild(_overlaySpinner);
    
    //---------------------------------------------------------------
    // Sprites
    //---------------------------------------------------------------
    _grinTag = _loadImage("resources/grin.svg", 32, 32, -400.0, 0.0, true);
    _fireTag = _loadImage("resources/fire.svg", 32, 32, -200.0, 0.0, true);
    _giftTag = _loadImage("resources/gift.svg", 32, 32, 0.0, 0.0, true);
    _evilTag = _loadImage("resources/evil.svg", 32, 32, 200.0, 0.0, true);
    _rocketTag = _loadImage("resources/rocket.svg", 32, 32, 400.0, 0.0, true);
  }
  
  int _loadImage(String resource, int width, int height, double px, double py, [bool simulateLoadingDelay = false]) {
    Ranger.Application app = Ranger.Application.instance;
    Resources resources = GameManager.instance.resources;

    _loadingCount++;
    
    // Grab current tag prior to bumping.
    int tg = _nextTag;
    
    // I use a Closure to capture the placebo sprite such that it can
    // be used while the actual image is loading.
    (int ntag) {  // <--------- Closure
      // While the actual image is loading, display an animated placebo.
      Ranger.SpriteImage placebo = resources.getSpinner(7000);
      // Track this infinite animation.
      app.animations.track(placebo, Ranger.TweenAnimation.ROTATE);
      
      placebo.setPosition(px, py);
      addChild(placebo, 10);
      
      // Start loading image
      // This Template example enables Simulated Loading Delay. You
      // wouldn't do this in production. Just leave the parameter missing
      // as it is optional and defaults to "false/disabled".
      //                                         ^-------v
      resources.loadImage(resource, width, height, simulateLoadingDelay).then((ImageElement ime) {
        // Image has finally loaded.
        // Terminate placebo's animation.
        app.animations.flush(placebo);

        // Remove placebo and capture index for insertion of actual image.
        int index = removeChild(placebo);
        
        // Now that the image is loaded we can create a sprite from it.
        Ranger.SpriteImage spri = new Ranger.SpriteImage.withElement(ime);
        // Add the image at the place-order of the placebo.
        addChildAt(spri, index, 10, ntag);
        spri.setPosition(px, py);

        _loadingCount--;
        
        _loadingUpdate(ntag);
      });
    }(tg);// <---- Immediately execute the Closure.
    
    _nextTag++;
    
    return tg;
  }
  
}
