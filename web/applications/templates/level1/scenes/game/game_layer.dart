part of template1;

/**
 * A simple layer that demonstrates async loading while displaying a
 * placebo image during loading.
 * 
 * In a real production app you would want to create a resource loading
 * framework that uses the concepts of this example.
 */
class GameLayer extends Ranger.BackgroundLayer {
  Ranger.SpriteImage _grin;
  
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

      _configure();
    }
    
    return true;
  }
  
  void _configure() {
    //---------------------------------------------------------------
    // Create nodes.
    //---------------------------------------------------------------
    Ranger.TextNode desc = new Ranger.TextNode.initWith(Ranger.Color4IDartBlue);
    desc.text = "Ranger GameLayer";
    desc.shadows = true;
    desc.setPosition(-450.0, 200.0);
    desc.uniformScale = 10.0;
    addChild(desc, 10, 445);

    Ranger.Application app = Ranger.Application.instance;
    Resources resources = GameManager.instance.resources;

    // I use an anonymous Closure to capture the placebo sprite such that it can
    // be used when the actual image is being loaded.
    () {  // <--------- Closure
      // While the actual image is loading, display an animated placebo.
      Ranger.SpriteImage placebo = new Ranger.SpriteImage.withElement(resources.spinner);
      addChild(placebo, 10, 7000);
      // Track this infinite animation.
      app.animations.track(placebo, Ranger.TweenAnimation.ROTATE);

      UTE.Tween rot = app.animations.rotateBy(
          placebo, 
          1.5,
          -360.0, 
          UTE.Linear.INOUT, null, false);
      //                 v---------^
      // Above we set "autostart" to false in order to set the repeat value
      // because you can't change the value after the tween has started.
      rot..repeat(UTE.Tween.INFINITY, 0.0)
         ..start();

      // Start loading image
      // This Template example enables Simulated Loading Delay. You
      // wouldn't do this in production. Just leave the parameter missing
      // as it is optional and defaults to "false/disabled".
      //                                         ^-------v
      resources.loadImage("resources/grin.svg", 32, 32, true).then((ImageElement ime) {
        // Image has finally loaded.
        // Terminate placebo's animation.
        app.animations.flush(placebo);

        // Remove placebo and capture index for insertion of actual image.
        int index = removeChild(placebo);
        
        // Now that the image is loaded we can create a sprite from it.
        _grin = new Ranger.SpriteImage.withElement(ime);
        _grin.uniformScale = 5.0;
        // Add the image at the place-order of the placebo.
        addChildAt(_grin, index, 10, 101);
      });
    }();// <---- I also use an IIF to execute the Closure.

  }
}
