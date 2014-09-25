part of ranger;

/**
 * NOT IMPLEMENTED at this time.
 */
class DrawWebGL extends DrawContext {
  // ----------------------------------------------------------
  // Properties
  // ----------------------------------------------------------
  WebGL.RenderingContext context;
  
  Matrix4 _transformMatrix = new Matrix4.identity();
  Matrix4 _stackMatrix = new Matrix4.identity();
  
  int _glServerState = 0;
  
  // ----------------------------------------------------------
  // Constructors and Factories
  // ----------------------------------------------------------
  DrawWebGL.withCanvas(Html.CanvasElement canvas);

  factory DrawWebGL(Html.CanvasElement canvas) {
    DrawWebGL drawer = new DrawWebGL.withCanvas(canvas);
    
    drawer.context = drawer.renderContext = canvas.getContext3d(stencil: true, preserveDrawingBuffer: true, alpha: false);
    if (drawer.renderContext == null) {
      // Couldn't create 3D context. Fallback to Canvas2D
      return null;
    }

    return drawer;
  }

  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  bool pointInside(Vector2 point) {
    return false;
  }

  void clear() {
    context.clear(WebGL.COLOR_BUFFER_BIT | WebGL.DEPTH_BUFFER_BIT);
  }

  void before() {
    
  }
  
  void after() {
    
  }
  
  void save() {
  }
  
  void restore() {
  }
  
  void transform(BaseNode node) {
    
  }
  
  @override
  void transformWith(AffineTransform t) {
  }

  @override
  void clip() {
  }

  void size(int width, int height) {
  }

  void configureBaseTransform() {
    
  }
  
  void set surfaceClearColor(Color4<int> color) {
    
  }

  /**
   * Override this method to draw your own node. 
   * The following GL states will be enabled by default: 
   *     - GL_VERTEX_ARRAY;  
   *     - GL_COLOR_ARRAY); 
   *     - GL_TEXTURE_COORD_ARRAY; 
   *     - GL_TEXTURE_2D;
   * and you should NOT DISABLE them afer drawing your [BaseNode]
   * But if you enable any other GL state, you should disable
   * it after drawing your node.
   */
  void draw() {
    
  }

  Vector2P mapWorldToView(double x, double y) {
    return null;
  }

  Vector2P mapViewToWorldWithPoint(Vector2 p) {
    return null;
  }
  
  Vector2P mapViewToWorld(int x, int y) {
    return null;
  }

  Vector2P mapViewToDesign(int x, int y) {
    return null;
  }

  MutableRectangle<double> mapViewRectToNode(BaseNode node, MutableRectangle<double> rect) {
    return null;
  }
  
  MutableRectangle<double> mapViewRectToWorld(MutableRectangle<double> rect) {
    return null;
  }
  
  Vector2P mapViewToNode(BaseNode node, int x, int y) {
    return null;
  }

}