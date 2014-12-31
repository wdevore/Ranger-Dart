part of ranger;

/** 
 * [BackgroundLayer] is a subclass of [LayerCascade] and is also the most
 * likely scenario of everyday usage. But ultimately it is an example to
 * springboard into a more complex layer.
 * 
 * This [Node] is meant as a background for your game and as such it has
 * extended functionality.
 * 
 * [BackgroundLayer] will cover the entire Design-space with a rectangle no
 * matter how you transform this [Layer] as long as the [constrainBackground] flag
 * remains true.
 * This allows [BackgroundLayer] to act like a backdrop for your game/application.
 */
class BackgroundLayer extends LayerCascade with MouseInputMixin, KeyboardInputMixin, TouchInputMixin {
  
  // These functions are set according to the Render context type.
  // I wouldn't recommend this in general. It is only done in this
  // node because BackgroundLayer is generic. You should create your own
  // custom Layer node targeting a specific context type.
  // The BackgroundLayer is here for completeness and as an 
  // example of a homogenous context type.
  // I would suggest you code for either WebGL or Canvas2D not both.
  
  Function updateColor;
  Function _draw;
  Function _setContentSize;

  AffineTransform t = new AffineTransform.Identity();
  /**
   * Constrain the background color to within the [Layer] itself. This
   * is the typical behavior expected.
   * Default is (true)
   */  
  bool constrainBackground = true;
  /**
   * Render a background color defined by [RGBACascadeBehavior.displayedColor].
   * Default is transparent = true
   */  
  bool transparentBackground = true;
  
  /// Mostly for development debugging.
  bool showOriginAxis = false;

  Vector2 _ls = new Vector2.zero();
  Vector2 _le = new Vector2.zero();

  BackgroundLayer();
  
  BackgroundLayer._();

  /**
   */
  factory BackgroundLayer.withColor([Color4<int> color]) {
    BackgroundLayer layer = new BackgroundLayer._();
    if (layer.init()) {
      if (color != null) {
        layer.color = color;
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
   * Application.instance.sceneManager.ignoreClear = true;
   * 
   * (Default is false)
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

    if (super.init(width, height)) {
      if (width != null && height != null)
        setContentSize(width.toDouble(), height.toDouble());
      else if (width != null && height == null)
        setContentSize(width.toDouble(), contentSize.height);
      else if (width == null && height != null)
        setContentSize(contentSize.width, height.toDouble());
    }
    
    return true;
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

  void set color(Color4<int> color) {
    if (color != null) {
      super.color = color;
      updateColor();
    }
  }

  @override
  void setContentSize(double width, double height) {
    _setContentSize(width, height);
    if (centered) {
      setPosition(width / 2.0, height / 2.0);
    }
  }  

  void _setContentSizeForCanvas(double width, double height) {
    super.setContentSize(width, height);
  }
  
  void _setContentSizeForWebGL(double width, double height) {
    // TODO WebGL adjust vertices and bind buffers.
//    var locSquareVertices = this._squareVertices;
//    locSquareVertices[1].x = size.width;
//    locSquareVertices[2].y = size.height;
//    locSquareVertices[3].x = size.width;
//    locSquareVertices[3].y = size.height;
//    this._bindLayerVerticesBufferData();
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
    //context.drawRect(-position.x, -position.y, size.width, size.height, true, false);
    // Or apply t.translate and then x,y can be zero.
    if (!transparentBackground) {
      context.drawRect(0.0, 0.0, size.width, size.height);
    }
  }
  
  void _drawCanvas(DrawContext context) {
    // We always want BackgroundLayer to cover the entire area with a
    // rectangle. This means we need to remove any transforms applied
    // to this Node prior to drawing the rectangle.
    
    // Applying t.translate here allows us to use zero for x,y below.
    context.save();

    // TODO we should not be calling toString() on every draw. Convert displayedColor to String.
    context.fillColor = displayedColor.toString();
    
    if (constrainBackground) {
      // TODO migrate to dirty method
      // Use the anchor to force the layer color back into center view.
      if (anchoredScene == null) {
        print("BackgroundLayer ${tag} : Warning! anchor not set. Background will not be constrained to fill scene.");
      }
      else {
        t.toIdentity();
        double xt = anchoredScene.anchor.position.x + position.x;
        double yt = anchoredScene.anchor.position.y + position.y;
        
        t.translate(xt, yt);
        // We don't negate rotation and scale because we dont' want those effects
        // to apply this layer.
        //t.rotate(rotation);
        //t.scale(uniformScale, uniformScale);
        t.invert();
        context.transformWith(t);
      }
    }

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
  
  // ----------------------------------------------------------
  // RGBA behavior
  // ----------------------------------------------------------
  void setOpacity(int opacity) {
    super.cascadeOpacity(opacity);
    updateColor();
  }
  
  void setColor(Color4<int> color) {
    super.cascadeColor(color);
    updateColor();
  }
  
  void enableInputs() {
    if (mouseEnabled) {
      bindMouseEvents();
    }

    if (keyboardEnabled) {
      bindKeyboardEvents();
    }
    
    if (touchEnabled) {
      bindTouchEvents();
    }
  }
  
  void disableInputs() {
    if (mouseEnabled) {
      unbindMouseEvents();
    }
    
    if (keyboardEnabled) {
      unbindKeyboardEvents();
    }
    
    if (touchEnabled) {
      unbindTouchEvents();
    }
  }
  
  /*
   * Override onEnter in order to enable input features.
   */
  @override
  void onEnter() {
    enableInputs();    
    super.onEnter();
  }

  @override
  void onExit() {
    super.onExit();
    disableInputs();
  }
}

