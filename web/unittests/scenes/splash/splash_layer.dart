part of unittests;

/**
 * Show Ranger-Dart logo
 * animate "Rocket Dart" in from bottom.
 * animate "Version 0.0.1" in from bottom delayed by a fraction of second.
 */
class SplashLayer extends Ranger.BackgroundLayer {
  Ranger.SpriteImage _spriteLogo;
  
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
    Ranger.Application app = Ranger.Application.instance;
    
    double hHeight = app.designSize.height / 2.0;
    
    _spriteLogo = new Ranger.SpriteImage.withElement(GameManager.instance.resources.rangerLogo);
    addChild(_spriteLogo, 10, 700);
    
    //---------------------------------------------------------------
    // Create text nodes.
    //---------------------------------------------------------------
    Ranger.TextNode title = new Ranger.TextNode.initWith(Ranger.Color4IOrange);
    title.text = "Unit Tests-o-rama";
    title.setPosition(-400.0, -(hHeight) - 80.0);
    title.uniformScale = 10.0;
    title.shadows = true;
    //rocketText.strokeColor = Ranger.Color4IBlack;
    //rocketText.strokeWidth = 0.3;
    addChild(title, 10, 701);
    
    Ranger.TextNode version = new Ranger.TextNode.initWith(Ranger.Color4IDartBlue);
    version.text = "${Ranger.CONFIG.ENGINE_NAME} ${Ranger.CONFIG.ENGINE_VERSION}";
    version.strokeColor = Ranger.Color4IBlack;
    version.shadows = true;
    version.strokeWidth = 0.3;
    version.setPosition(-410.0, hHeight + 35.0);
    version.uniformScale = 10.0;
    addChild(version, 10, 702);

    //---------------------------------------------------------------
    // Begin animating text into view.
    //---------------------------------------------------------------
    // Because the TextNode isn't a Tweenable we need to register the 
    // class with the Tween system in order to recognize and animate it.
    UTE.Tween.registerAccessor(Ranger.TextNode, app.animations);

    UTE.Timeline par = new UTE.Timeline.parallel();

    UTE.Timeline seq = new UTE.Timeline.sequence();
    seq.pushPause(0.5);
    
    double vertPos = hHeight - (app.designSize.height / 3.0);
    
    UTE.Tween mTw1 = app.animations.moveBy(
        title, 
        0.5,
        vertPos, 0.0,
        UTE.Cubic.OUT, Ranger.TweenAnimation.TRANSLATE_Y, null, false);
    
    seq.push(mTw1);
    par.push(seq);

    UTE.Timeline seq2 = new UTE.Timeline.sequence();
    seq2.pushPause(1.0);
    UTE.Tween mTw2 = app.animations.moveBy(
        version, 
        0.5,
        -200.0, 0.0,
        UTE.Cubic.OUT, Ranger.TweenAnimation.TRANSLATE_Y, null, false);
    
    seq2.push(mTw2);
    par.push(seq2);

    // Note we don't pass in the app.animations.tweenMan because
    // The Application class has already "registered" the TweenAnimation's
    // TweenManager with the Scheduler. If you pass in the tweenMan then
    // the animations will run twice as fast because the tweenMan is
    // being ticked twice.
    par.start();

  }
  

}
