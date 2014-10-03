part of ranger_rocket;

/*
  */
class Resources {
  ImageElement rangerLogo;

  static const int BASE_ICON_SIZE = 32;
  
  ImageElement spinner;
  ImageElement spinner2;

  int _iconLoadCount = 0;
  int _iconTotal = 0;

  int _bootLoadCount = 0;
  int _bootTotal = 0;

  /// Loaded icons are centered automatically.
  bool autoCenter = true;
  
  Completer _bootWorker;
  Completer _baseWorker;

  Function _loadedCallback;

  bool _bootInitialized = false;
  bool _baseInitialized = false;
  
  bool get isBootResourcesReady => _bootInitialized;
  bool get isBaseResourcesReady => _baseInitialized;
  
  Resources() {
    // These spinners are embedded resources so they are always available.
    spinner = new ImageElement(
        src: Ranger.BaseResources.svgMimeHeader + Ranger.BaseResources.spinner,
        width: 32, height: 32);

    spinner2 = new ImageElement(
        src: Ranger.BaseResources.svgMimeHeader + Ranger.BaseResources.spinner2,
        width: 512, height: 512);
  }

  Future loadBootResources() {
    _bootWorker = new Completer();

    if (_bootInitialized)
      _bootWorker.complete();
    
    _loadBootImage((ImageElement ime) {rangerLogo = ime;}, "resources/RangerDart.png", 960, 540);

    return _bootWorker.future;
  }

  Future loadBaseResources() {
    _baseWorker = new Completer();

    //_loadBaseImage((ImageElement ime) {list = ime;}, "resources/list.svg", BASE_ICON_SIZE, BASE_ICON_SIZE);


    return _baseWorker.future;
  }

  Future<ImageElement> loadImage(String source, int iWidth, int iHeight, [bool simulateLoadingDelay = false]) {
    Ranger.ImageLoader loader = new Ranger.ImageLoader.withResource(source);
    loader.simulateLoadingDelay = simulateLoadingDelay;
    return loader.load(iWidth, iHeight);
  }
  
  void _loadBootImage(Ranger.ImageLoaded loaded, String source, int iWidth, int iHeight) {
    _bootTotal++;
    Ranger.ImageLoader loader = new Ranger.ImageLoader.withResource(source);
    loader.load(iWidth, iHeight).then((ImageElement ime) {
      loaded(ime);
      _bootImageLoaded();
    });
  }
  
  void _loadBaseImage(Ranger.ImageLoaded loaded, String source, int iWidth, int iHeight) {
    _iconTotal++;
    Ranger.ImageLoader loader = new Ranger.ImageLoader.withResource(source);
    loader.load(iWidth, iHeight).then((ImageElement ime) {
      loaded(ime);
      _onBaseComplete();
    });
  }
  
  void _bootImageLoaded() {
    _bootLoadCount++;
    _checkBootCompleteness();
  }

  void _onBaseComplete() {
    _iconLoadCount++;
    _checkForCompleteness();
  }

  bool get isBaseLoaded => _iconLoadCount == _iconTotal; 
  bool get isBootLoaded => _bootLoadCount == _bootTotal; 
  
  void _checkForCompleteness() {
    if (isBaseLoaded) {
      _baseInitialized = true;
      _baseWorker.complete();
    }
  }

  void _checkBootCompleteness() {
    if (isBootLoaded) {
      _bootInitialized = true;
      _bootWorker.complete();
    }
  }
  
  Ranger.SpriteImage getSpinner(int tag) {
    Ranger.Application app = Ranger.Application.instance;
    Ranger.SpriteImage si = new Ranger.SpriteImage.withElement(spinner);
    si.tag = tag;
    
    UTE.Tween rot = app.animations.rotateBy(
        si, 
        1.5,
        -360.0, 
        UTE.Linear.INOUT, null, false);
    //                 v---------^
    // Above we set "autostart" to false in order to set the repeat value
    // because you can't change the value after the tween has started.
    rot..repeat(UTE.Tween.INFINITY, 0.0)
       ..start();
    
    return si;
  }
  
  /**
   * [lapTime] how long to make one rotation/arc of the given [deltaDegrees].
   */
  Ranger.SpriteImage getSpinnerRing(double lapTime, double deltaDegrees, int tag) {
    Ranger.Application app = Ranger.Application.instance;
    Ranger.SpriteImage si = new Ranger.SpriteImage.withElement(spinner2);
    si.tag = tag;
    
    UTE.Tween rot = app.animations.rotateBy(
        si, 
        lapTime,
        deltaDegrees, 
        UTE.Linear.INOUT, null, false);
    //                 v---------^
    // Above we set "autostart" to false in order to set the repeat value
    // because you can't change the value after the tween has started.
    rot..repeat(UTE.Tween.INFINITY, 0.0)
       ..start();
    
    return si;
  }

}