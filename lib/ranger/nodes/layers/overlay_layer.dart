part of ranger;

/** 
 * [OverlayLayer] is a subclass of [Layer].
 * Use it soley for overlays--typically translucent or transparent backgrounds.
 * 
 * This [Node] is meant as a foreground for your game.
 * 
 * [OverlayLayer] will cover the entire Design-space with a rectangle no
 * matter how you transform this [Layer] as long as the [constrainBackground] flag
 * remains true.
 */
class OverlayLayer extends Layer {
  
  // These functions are set according to the Render context type.
  // I wouldn't recommend this in general. It is only done in this
  // node because OverlayLayer is generic. You should create your own
  // custom Layer node targeting a specific context type.
  // The OverlayLayer is here for completeness and as an 
  // example of a homogenous context type.
  // I would suggest you code for either WebGL or Canvas2D not both.
  
  Function updateColor;
  Function _draw;
  Function _setContentSize;

  String overlayColor;
  
  AffineTransform t = new AffineTransform.Identity();
  /**
   * Constrain the background color to within the [Layer] itself. This
   * is the typical behavior expected.
   * Default is (true)
   */  
  bool constrainBackground = true;
  /**
   * Render a background color defined by [overlayColor].
   * Default is (true)
   */  
  bool transparentBackground = true;
  
  /// Mostly for development debugging.
  bool showOriginAxis = false;

  Vector2 _ls = new Vector2.zero();
  Vector2 _le = new Vector2.zero();

  OverlayLayer();
  
  OverlayLayer._();

  /**
   */
  factory OverlayLayer.withColor([Color4<int> color]) {
    OverlayLayer layer = new OverlayLayer._();
    if (layer.init()) {
      if (color != null) {
        layer.overlayColor = color.toString();
      }
      
      return layer;
    }
    
    return null;
  }
  
  /**
   * [init] defaults to using the Design dimensions.
   * 
   * Some [Layer] nodes are "static" in functionality, meaning there
   * is no transition effects in motion. If that is the case then
   * you can take the default which is that the [SceneManager] won't
   * clear the background because the [Layer] is covering it completely.
   * In other words the background is fully occluded.
   * [Application.instance.sceneManager.ignoreClear] = true;
   * (Default is false)
   * 
   * However, some [Layer]s may be under the effects of transitions and
   * as such the background will need to be cleared on every frame
   * because the Surface may be exposed leading to rendering artifacts.
   * In this case your [Layer] will need to change the clear flag to
   * false "after" the init().
   * 
   * if [width] and [height] are not provided then
   * designSize.width, designSize.height are used.
   */
  @override
  bool init([int width, int height]) {
    // Default to "clearing the background".
    // Be sure to set the DrawContext.surfaceClearColor when using
    // "false".
    Application.instance.sceneManager.ignoreClear = false;
    
    // Runtime binding.
    if (Application.instance.isCanvasContext) {
      _draw = _drawCanvas;
      updateColor = _updateColorCanvas;
      _setContentSize = _setContentSizeForCanvas;
    }
    else {
      _draw = _drawWebGL;
      updateColor = _updateColorWebGL;
      _setContentSize = _setContentSizeForWebGL;
    }

    // Init is called last because the class heiarchy relies on
    // _setContentSize being bound first.
    if (width != null && height != null)
      setContentSize(width.toDouble(), height.toDouble());
    else if (width != null && height == null)
      setContentSize(width.toDouble(), contentSize.height);
    else if (width == null && height != null)
      setContentSize(contentSize.width, height.toDouble());
    
    return super.init(width, height);
  }

  /**
   * [width] and [height] are in Points
   */
  void setWidthAndHeight(int width, int height) {
    setContentSize(width.toDouble(), height.toDouble());
  }

  /**
   * [width] is in Points
   */
  void setWidth(int width) {
    setContentSize(width.toDouble(), contentSize.height);
  }

  /**
   * [height] is in Points
   */
  void setHeight(int height) {
    setContentSize(contentSize.width, height.toDouble());
  }

  @override
  void setContentSize(double width, double height) {
    _setContentSize(width, height);
  }  

  void _setContentSizeForCanvas(double width, double height) {
    super.setContentSize(width, height);
  }
  
  void _setContentSizeForWebGL(double width, double height) {
    // TODO WebGL adjust vertices and bind buffers.
    super.setContentSize(width, height);
  }
  
  void _updateColorCanvas() {
  }
  
  // TODO WebGL
  void _updateColorWebGL() {
    
  }
  
  // ----------------------------------------------------------
  // Rendering
  // ----------------------------------------------------------
  @override
  void draw(DrawContext context) {
    _draw(context);
  }
  
  void drawBackground(DrawContext context) {
    Size<double> size = contentSize;
    if (!transparentBackground) {
      context.drawRect(-size.width / 2.0, -size.height / 2.0, size.width, size.height);
    }
  }
  
  void _drawCanvas(DrawContext context) {
    // We always want OverlayLayer to cover the entire area with a
    // rectangle. This means we need to remove any transforms applied
    // to this Node prior to drawing the rectangle.
    
    context.save();
    context.fillColor = overlayColor;

//    if (constrainBackground) {
//      // TODO migrate to dirty method
//      // Use the anchor to force the layer color back into center view.
//      if (anchoredScene == null) {
//        print("OverlayLayer ${tag} : Warning! anchor not set. Background will not be constrained to fill scene.");
//      }
//      else {
//        t.toIdentity();
//        double xt = anchoredScene.anchor.position.x + position.x;
//        double yt = anchoredScene.anchor.position.y + position.y;
//        
//        t.translate(xt, yt);
//        // We don't negate rotation and scale because we dont' want those effects
//        // to apply this layer.
//        //t.rotate(rotation);
//        //t.scale(uniformScale, uniformScale);
//        t.invert();
//        context.transformWith(t);
//      }
//    }

    drawBackground(context);
    
    context.restore();

    if (showOriginAxis) {
      context.save();
      context.lineWidth = 3.0;
      context.drawColor = "rgba(255,255,255,1.0)";
      _ls.setValues(0.0, 0.0);
      _le.setValues(25.0, 0.0);
      context.drawLine(_ls, _le);
      context.drawColor = "rgba(255,0,0,1.0)";
      _ls.setValues(25.0, 0.0);
      _le.setValues(50.0, 0.0);
      context.drawLine(_ls, _le);
  
      context.drawColor = "rgba(255,255,255,1.0)";
      _ls.setValues(0.0, 0.0);
      _le.setValues(0.0, 25.0);
      context.drawLine(_ls, _le);
      context.drawColor = "rgba(0,255,0,1.0)";
      _ls.setValues(0.0, 25.0);
      _le.setValues(0.0, 50.0);
      context.drawLine(_ls, _le);
      context.lineWidth = 1.0;
      context.restore();
    }
    
  }
  
  // TODO WebGL
  void _drawWebGL(DrawContext context) {
    
  }
  
}

