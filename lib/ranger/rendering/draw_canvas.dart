part of ranger;

/**
 * An simple "non optimal" Html5 Canvas rendering implementation.
 * It is most used for Unit tests, experimentation and simple applications.
 * Use it as a guide to create a more robust implementation.
 * You are not required to use any of the drawing methods. Your [Node]
 * would would do the rendering instead.
 */
class DrawCanvas extends DrawContext {

  Html.CanvasRenderingContext2D context;
  
  AffineTransform baseTransform = new AffineTransform.Identity();
  AffineTransform invBaseTransform;
  
  // TODO This is a confused hack. It shouldn't be required for text
  // but for some reason the canvas context must be using a different
  // transform internally. So I have to invert during text rendering.
  AffineTransform inverseTextTransform = new AffineTransform.IdentityP();

  Vector2 tp = new Vector2.zero();
  
  DrawCanvas.withCanvasAndScale(Html.CanvasElement canvas, Point scaleFactor, [bool flipped = false]);

  DrawCanvas._();
  
  factory DrawCanvas([bool flipped = false]) {
    DrawCanvas drawer = new DrawCanvas._();
    drawer._flipped = flipped;
    return drawer;
  }
  
  /**
   * [flipped] = true then +Y axis is downward and origin at bottom.
   */
  factory DrawCanvas.withCanvas(Html.CanvasElement canvas, Point scaleFactor, int width, int height, [bool flipped = false]) {
    DrawCanvas drawer = new DrawCanvas.withCanvasAndScale(canvas, scaleFactor, flipped);
    drawer.canvas = canvas;
    
    drawer.context = drawer.renderContext = canvas.context2D;
    
    drawer.scale.x = scaleFactor.x;
    drawer.scale.y = scaleFactor.y;
        
    drawer.size(width, height);
    
    // Default background color for Scenes, Layers may overlay it.
    canvas.style.backgroundColor = drawer._surfaceClearColor.toStringRGB();
    canvas.style.opacity = drawer._surfaceClearColor.alphaAsFraction.toString();

    return drawer;
  }

  @override
  set canvas(Html.CanvasElement canvas) {
    super.canvas = canvas;
    context = renderContext = canvas.context2D;
    
    // Default background color for Scenes, Layers may overlay it.
    canvas.style.backgroundColor = _surfaceClearColor.toStringRGB();
    canvas.style.opacity = _surfaceClearColor.alphaAsFraction.toString();
  }
  
  bool pointInside(Vector2 point) {
    return context.isPointInPath(point.x, point.y);
  }

  @override
  set surfaceClearColor(Color4<int> color) {
    _surfaceClearColor.r = color.r;
    _surfaceClearColor.g = color.g;
    _surfaceClearColor.b = color.b;
    _surfaceClearColor.a = color.a;
    canvas.style.backgroundColor = _surfaceClearColor.toStringRGB();
    canvas.style.opacity = _surfaceClearColor.alpha.toString();
  }
  
  // Layers typically don't need this because they act as a clearing effect.
  void clear() {
    // Clears based on canvas.style.backgroundColor
    //print("DrawCanvas.clear: $_width, $_height");
    context.clearRect(0, 0, _width, _height);
    
    //Html.Rectangle rect = canvas.getBoundingClientRect();
    //print("DrawCanvas.clear: ${rect}");
    //context.clearRect(rect.left, rect.top, rect.width, rect.height);
  }
  
  void before() {
    if (clippingEnabled) {
      context.beginPath();
      context.rect(0.0, 0.0, _width, _height);
      context.clip();
      //print("DrawCanvas.before: clip $_width, $_height");
    }
    
    // Only needed if your Node doesn't cover the entire area of the
    // design view. BackgroundLayer does by design so this isn't needed.
    // context.clearRect(0, 0, _width, _height);
  }
  
  void after() {
  }

  void save() {
    context.save();
    _prevFilled = filled;
    _prevOutlined = outlined;
    _prevFont = font;
    _prevLineWidth = lineWidth;
    //_prevFillColor = fillColor;
    //_prevDrawColor = drawColor;
  }
  
  void restore() {
    context.restore();
    filled = _prevFilled;
    outlined = _prevOutlined;
    font = _prevFont;
    lineWidth = _prevLineWidth;
    //fillColor = _prevFillColor;
    //drawColor = _prevDrawColor;
  }
  
  void size(int width, int height) {
    _width = width;
    _height = height;
    
    // Note: on some browsers changing the Canvas2D's width will cause
    // the transform to reset to the Identity matrix.
    // Therefore, we need to rebuild the base transform.
    configureBaseTransform();
  }

  @override
  void transformWith(AffineTransform t) {
    context.transform(t.a, t.b, t.c, t.d, t.tx, t.ty);
  }

  @override
  void clip() {
    context.beginPath();
    Html.Rectangle rect = canvas.getBoundingClientRect();
    context.rect(rect.left, rect.top, rect.width, rect.height);
    context.clip();
  }

  void configureBaseTransform() {
    // Note: The order of transforms are important. Canvas applies transforms
    // in a post-multiply notation (column major) verse other row major
    // systems.
    // Therefore scale needs to be last.
    // Otherwise you end up scaling a translated system; a zooming effect.
    baseTransform.toIdentity();
    
    /* 
     * By default Canvas2D's origin at the top-left with Y axis pointing
     * "down".
     * 
     *    non-visible area
     * 0,0--------------> X
     * |
     * |   . <--- 50,50
     * |   visible area
     * |
     * |
     * v Y
     * 
     * We may want the origin at the bottom-left (flipped). To do
     * this we perform two steps:
     *    1) translate the coordinate system downwards
     *    2) invert the Y axis
     *    
     * Before the flip:
     * ^ Y
     * |
     * | 
     * |   non-visible area
     * |
     * |
     * 0,0--------------> X
     * |
     * |   . <--- -50,50
     * |   visible area
     * |
     * |
     * v
     * 
     * But the Canvas's coordinate origin is still at the top-left which
     * means a circle drawn at 50,50 will be drawn "off-screen", you
     * won't be able to see it. Effectively the +Y values are off-screen.
     * 
     * So we fix it my translating the coordinate system "downwards" by the
     * height of the canvas element effectively putting the origin
     * at the bottom-left which gives us:
     * 
     * ^ Y
     * |
     * | 
     * |   visible area
     * |   . <--- 50,50
     * |
     * 0,0--------------> X
     * |
     * |   non-visible area
     * |
     * |
     * v
     * 
     * The +Y values are now back "on-screen".
     */

    // Spaces.
    // When Ranger speaks of view-space it is the same as referencing
    // mouse-space, canvas-space or window-space. They are synonymous.
    // 
    // Once the baseTransform is applied you now have a new space called:
    // Design-space. This space is NOT synonymous with world-space.
    // Design-space is simply used when rendering along the context
    // transformation stack.
    //
    // World-space is the inverse of the baseTransform. World-space is
    // where the mouse would be if there were no design-space scaling.
    // It a flipped and translated version of view-space; we don't want
    // the Design-space scaling to be introduced into World-space.
    // World-space is what you use when mapping to Node-space.
    //
    // Note: For the following discussion I am going to ignore the Design
    // to view scale ratio for now to make it easier to visualize, and we
    // are using the "flipped" orientation.
    // Let's say your view-space size is 1120x700 and you have a point at
    // 200,200 (aka mouse position).
    // You apply the baseTransform to which you get 200,500.
    // This means that 200,200 has mapped to 200,500 in Design-space.
    // Keep in mind that the view-space point hasn't actually moved it is
    // still at 200,200 where your mouse is. The mouse is now hovering
    // over 200,500 in Design-space.
    
    if (_flipped) {
      // Move origin to bottom
      baseTransform.translate(0.0, canvas.height.toDouble());
      
      // Invert the Y axis so it points "upwards"
      // However, all rotations that were CW now become CCW.
      baseTransform.scale(1.0, -1.0);
    }
    
    // Concatenate Design-to-View ratio scaling.
    baseTransform.scale(scale.x, scale.y);
    //print("Design scale ratio: $scale");
    
    //print("baseTransform:\n$baseTransform");
    
    context.setTransform(
        baseTransform.a, 
        baseTransform.c, 
        baseTransform.b, 
        baseTransform.d, 
        baseTransform.tx, baseTransform.ty);
    
    invBaseTransform = new AffineTransform.withAffineTransformP(baseTransform);
    invBaseTransform.invert();
    //print("invBaseTransform:\n$invBaseTransform");
  }
  
  void transform(BaseNode node) {
    AffineTransform t = node.calcTransform();
    context.transform(t.a, t.b, t.c, t.d, t.tx, t.ty);
  }
  
  // ----------------------------------------------------------
  // Drawing
  // ----------------------------------------------------------
  /**
   * draws a point given x and y coordinate measured in points.
   */
  @override
  drawPointAt(double x, double y, [int size]) {
    if (size == null) {
      size = 1;
    }

    if (filled) {
      context..fillStyle = fillColor
             ..beginPath()
             ..arc(x, y, size, 0, DrawContext.TPi)
             ..closePath()
             ..fill();
      Application.instance.objectsDrawn++;
    }

    if (outlined) {
      context..strokeStyle = drawColor
             ..lineWidth = lineWidth
             ..beginPath()
             ..arc(x, y, size, 0, DrawContext.TPi)
             ..closePath()
             ..stroke();
      Application.instance.objectsDrawn++;
    }
    
  }

  /**
   * draws a point given x and y coordinate measured in points.
   */
  @override
  drawPoint(Vector2 point, [int size]) {
    drawPointAt(point.x, point.y, size);
  }

  @override
  void drawLine(Vector2 origin, Vector2 destination) {
    context..beginPath()
           ..strokeStyle = drawColor
           ..moveTo(origin.x, origin.y)
           ..lineWidth = lineWidth
           ..lineTo(destination.x, destination.y)
           ..stroke();
    
    Application.instance.objectsDrawn++;
  }

  @override
  void drawText(String text, Vector2 pos) {
    if (horzAlign != null)
      context.textAlign = horzAlign;
    if (baseLine != null)
      context.textBaseline = baseLine;

    if (CONFIG.base_coordinate_system == CONFIG.LEFT_HANDED_COORDSYSTEM) {
      inverseTextTransform.toIdentity();
      inverseTextTransform.scale(1.0, -1.0);
      inverseTextTransform.translate(-pos.x, -pos.y);
      transformWith(inverseTextTransform);
    }
    
    if (font != null) {
      context.font = font;
    }
    
    if (shadows) {
      context.shadowColor = "rgba(0, 0, 0, 0.8)";
      context.shadowOffsetX = 5;
      context.shadowOffsetY = 5;
      context.shadowBlur = 10;
    }
    
    if (filled) {
      context..fillStyle = fillColor
             ..fillText(text, pos.x, pos.y);
    }
    
    if (outlined) {
      context..lineWidth = lineWidth
             ..strokeStyle = drawColor
             ..strokeText(text, pos.x, pos.y);
    }
    
    Application.instance.objectsDrawn++;
  }

  void drawLineByComp(double x1, double y1, double x2, double y2) {
    context..beginPath()
           ..strokeStyle = drawColor
           ..moveTo(x1, y1)
           ..lineWidth = lineWidth
           ..lineTo(x2, y2)
           ..stroke();
    
    Application.instance.objectsDrawn++;
  }

  @override
  void drawRect(double left, double bottom, double width, double height) {
//    if (filled) {
//      context..beginPath()
//             ..rect(left, bottom, width, height)
//             ..fillStyle = fillColor
//             ..fill();
//    }
//    
//    if (outlined) {
//      context..beginPath()
//             ..rect(left, bottom, width, height)
//             ..strokeStyle = drawColor
//             ..stroke();
//    }

    // Or style #2
    if (filled) {
      context..fillStyle = fillColor
             ..fillRect(left, bottom, width, height);
    }

    // Note: strokes can scale to the point that the fill can't be seen.
    // An inverse scale is needed if the fill is scaled.
    if (outlined) {
      context..strokeStyle = drawColor
             ..lineWidth = lineWidth
             ..strokeRect(left, bottom, width, height);
    }    

    Application.instance.objectsDrawn++;
  }

  void createPath(List<Vector2> vertices, bool closePolygon) {
    context..beginPath()
           ..moveTo(vertices[0].x, vertices[0].y);
    
    for(int i = 1; i < vertices.length; i++)
      context.lineTo(vertices[i].x, vertices[i].y);
    
    if (closePolygon == DrawContext.CLOSED)
      context.closePath();
    
    Application.instance.objectsDrawn++;
  }
  
  @override
  void drawPoly(List<Vector2> vertices, bool closePolygon, bool solid) {
    createPath(vertices, closePolygon);
    if (solid == DrawContext.SOLID) {
      context..fillStyle = fillColor
             ..fill();
    }
    else {
      context..strokeStyle = drawColor
             ..lineWidth = lineWidth
             ..stroke();
    }
    
    Application.instance.objectsDrawn++;
  }

  /**
   * maps a view-space point to design-space point.
   */
  /// Returns a poolable object.
  Vector2P mapViewToDesign(int x, int y) {
    tp.setValues(x.toDouble(), y.toDouble());
    Vector2P p = PointApplyAffineTransform(tp, baseTransform);
    return p;
  }

  /// Returns a poolable object.
  Vector2P mapWorldToView(double x, double y) {
    tp.setValues(x, y);
    Vector2P p = PointApplyAffineTransform(tp, baseTransform);
    return p;
  }

  /// Returns a poolable object.
  Vector2P mapViewToWorldWithPoint(Vector2 viewPoint) {
    // To map coordinates to any Nodes in a Scene you must use world-space
    // coordinates. By using the inverse transform on mouse-space
    // points you are effectively mapping to world-space and not
    // design-space.
    Vector2P p = PointApplyAffineTransform(viewPoint, invBaseTransform);
    return p;
  }
  
  /// Returns a poolable object.
  Vector2P mapViewToWorld(int x, int y) {
    tp.setValues(x.toDouble(), y.toDouble());
    return mapViewToWorldWithPoint(tp);
  }

  /// Returns a poolable object.
  MutableRectangle<double> mapViewRectToWorld(MutableRectangle<double> rect) {
    MutableRectangle<double> nodeAABBox = new MutableRectangle<double>.withP(
        0.0, 0.0, 0.0, 0.0);

    RectApplyAffineTransformTo(rect, nodeAABBox, invBaseTransform);
    
    return nodeAABBox;
  }
  
  /// Returns a poolable object.
  MutableRectangle<double> mapViewRectToNode(BaseNode node, MutableRectangle<double> rect) {
    AffineTransform at = node.worldToNodeTransform();
    affineTransformMultiplyTo(invBaseTransform, at);
    
    MutableRectangle<double> nodeAABBox = new MutableRectangle<double>.withP(
        0.0, 0.0, 0.0, 0.0);

    RectApplyAffineTransformTo(rect, nodeAABBox, at);
    
    return nodeAABBox;
  }

  /**
   * [x], [y] are in view-space.
   * This method is typically used for selecting/picking.
   * Returns a poolable object.
   */
  Vector2P mapViewToNode(BaseNode node, int x, int y) {
    AffineTransform at = node.worldToNodeTransform();
//    affineTransformMultiplyTo(invBaseTransform, at);
//    tp.setValues(x.toDouble(), y.toDouble());
//    Vector2P p = PointApplyAffineTransform(tp, at);

    Vector2P dP = mapViewToWorld(x, y);
    Vector2P p = PointApplyAffineTransform(dP.v, at);
    dP.moveToPool();
    
    at.moveToPool();

    return p;
  }
}