part of template1;

/*
  */
class Resources {
  ImageElement spinner;
  
  static const int BASE_ICON_SIZE = 32;
  
  int _iconLoadCount = 0;
  int _iconTotal = 0;

  int _bootLoadCount = 0;
  int _bootTotal = 0;

  Completer _bootWorker;
  Completer _baseWorker;

  Function _loadedCallback;

  bool _bootInitialized = false;
  bool _baseInitialized = false;
  
  bool get isBootResourcesReady => _bootInitialized;
  bool get isBaseResourcesReady => _baseInitialized;
  
  Resources() {
    // The spinner is an embedded resource so it is always available.
    spinner = new ImageElement(
        src: Ranger.BaseResources.svgMimeHeader + Ranger.BaseResources.spinner,
        width: 32, height: 32);
  }
  
  Future loadBootResources() {
    _bootWorker = new Completer();

    if (_bootInitialized)
      _bootWorker.complete();
    
    //_loadBootImage((ImageElement ime) {grin = ime;}, "resources/grin.svg", 32, 32);

    return _bootWorker.future;
  }

  Future loadBaseResources() {
    _baseWorker = new Completer();

    //loadImage((ImageElement ime) {grin = ime;}, "resources/grin.svg", 32, 32);

    return _baseWorker.future;
  }

  void _loadBootImage(Ranger.ImageLoaded loaded, String source, int iWidth, int iHeight) {
    _bootTotal++;
    Ranger.ImageLoader loader = new Ranger.ImageLoader.withResource(source);
    loader.load(iWidth, iHeight).then((ImageElement ime) {
      loaded(ime);
      _bootImageLoaded();
    });
  }
  
  Future<ImageElement> loadImage(String source, int iWidth, int iHeight, [bool simulateLoadingDelay = false]) {
    Ranger.ImageLoader loader = new Ranger.ImageLoader.withResource(source);
    loader.simulateLoadingDelay = simulateLoadingDelay;
    return loader.load(iWidth, iHeight);
  }
  
  void _bootImageLoaded() {
    _bootLoadCount++;
    _checkBootCompleteness();
  }

  void _baseImageLoaded() {
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
  

}