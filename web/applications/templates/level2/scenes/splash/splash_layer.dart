part of template2;

/**
 * Show Ranger-Dart logo
 * animate "Rocket Dart" in from bottom.
 * animate "Version 0.0.1" in from bottom delayed by a fraction of second.
 */
class SplashLayer extends Ranger.BackgroundLayer {
  SplashLayer();
 
  factory SplashLayer.withColor(Ranger.Color4<int> backgroundColor, [bool centered = true, int width, int height]) {
    SplashLayer layer = new SplashLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = false;
    layer.color = backgroundColor;
    return layer;
  }

  @override
  void onEnter() {
    super.onEnter();

    _configure();
  }
  
  void _configure() {
    //---------------------------------------------------------------
    // Create text nodes.
    //---------------------------------------------------------------
    Ranger.TextNode title = new Ranger.TextNode.initWith(Ranger.Color4IOrange);
    title.text = "Splash Screen";
    title.setPosition(-350.0, 50.0);
    title.uniformScale = 10.0;
    title.shadows = true;
    addChild(title, 10, 701);
    
    Ranger.TextNode version = new Ranger.TextNode.initWith(Ranger.Color4IDartBlue);
    version.text = "${Ranger.CONFIG.ENGINE_NAME} ${Ranger.CONFIG.ENGINE_VERSION}";
    version.strokeColor = Ranger.Color4IWhite;
    version.strokeWidth = 1.0;
    version.shadows = true;
    version.setPosition(-600.0, -150.0);
    version.uniformScale = 15.0;
    addChild(version, 10, 702);
  }
  

}
