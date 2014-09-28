part of template0;

/**
 * A super simple layer.
 */
class GameLayer extends Ranger.BackgroundLayer {
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
    
    _configure();
    
    return true;
  }
  
  void _configure() {
    //---------------------------------------------------------------
    // Create nodes.
    //---------------------------------------------------------------
    Ranger.TextNode desc = new Ranger.TextNode.initWith(Ranger.Color4IDartBlue);
    desc.text = "Ranger GameLayer";
    desc.shadows = true;
    desc.setPosition(-450.0, 0.0);
    desc.uniformScale = 10.0;
    addChild(desc, 10, 445);
  }

}
