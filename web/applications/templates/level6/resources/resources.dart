part of template6;

/*
  */
class Resources {
  static int _nextTagId = 0;
  
  ImageElement spinner;
  ImageElement spinner2;
  
  static const int BASE_ICON_SIZE = 32;
  
  int _iconLoadCount = 0;
  int _iconTotal = 0;

  Completer _loadingWorker;

  Resources() {
    // These spinners are embedded resources so they are always available.
    spinner = new ImageElement(
        src: Ranger.BaseResources.svgMimeHeader + Ranger.BaseResources.spinner,
        width: 32, height: 32);

    spinner2 = new ImageElement(
        src: Ranger.BaseResources.svgMimeHeader + Ranger.BaseResources.spinner2,
        width: 512, height: 512);
  }
  
  Future<ImageElement> loadImage(String source, int iWidth, int iHeight, [bool simulateLoadingDelay = false]) {
    Ranger.ImageLoader loader = new Ranger.ImageLoader.withResource(source);
    loader.simulateLoadingDelay = simulateLoadingDelay;
    return loader.load(iWidth, iHeight);
  }
  
  bool get isBaseLoaded => _iconLoadCount == 0; 

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