part of ranger;

class RENDER_TYPE {
  static const int CANVAS = 0;
  static const int WEBGL = 1;
}

abstract class DrawContext {
  static const bool SOLID = true;
  static const bool OUTLINED = false;
  static const bool CLOSED = true;
  static const bool OPEN = false;

  static const double TPi = math.PI * 2.0;
  
  Html.CanvasElement canvas;

  /**
   * Is the base coordinate system either left or right handed.
   * 
   * 0,0--------------> X
   * |
   * |
   * |  Default
   * |
   * |
   * v Y
   * 
   *    
   * ^ Y
   * |
   * | 
   * | [_flipped] = true
   * |
   * |
   * 0,0--------------> X
   * 
   */
  bool _flipped = false;
  
  Point scale = new Point.zero();
  // These dimensions are tyically Design sizes.
  int _width;
  int _height;
  
  String _drawColor = "#000000";
  String _fillColor = "#aaaaaa";

  bool filled = true;
  bool outlined = false;
  
  bool _prevFilled = true;
  bool _prevOutlined = false;
  
  // Text features
  /// Horizontal alignment. Values: "start", "center", "end".
  /// Default is "start".
  String horzAlign;
  /// Baseline alignment. Values: "top", "middle", "bottom", "alphabetic",
  /// "ideographic". Default is "alphabetic"
  String baseLine;
  String font;
  bool shadows = false;
  String _prevFont;

  // This clear color appears underneath the Layer color. It typically
  // isn't visible unless the Layer size is smaller than the surface or
  // the surface is undergoing some form of transform, for example,
  // when animated by a scene transition.
  // If you are debugging it can appear depending on where your code
  // has "stopped".
  Color4<int> _surfaceClearColor = Color4IOrange;//Color4IGrey;
  
  Color4<int> get surfaceClearColor => _surfaceClearColor;
  
  double lineWidth = 1.0;
  double _prevLineWidth;
  
  /**
   * Clipping is optional (disable by default).
   * If the [Canvas] element's size is set you will not need to clip.
   * For example, if the Canvas size is
   * set to something similar to the container but your [BackgroundLayer] is set
   * to Design size then the [BackgroundLayer]'s rectangle will only cover
   * the design area leaving other portions "uncovered". This will
   * lead to improper clearing of the [BackgroundLayer] Node.
   * Hence, if you have a [Layer] that doesn't properly fill it's bounds
   * then you will get rendering artifacts.
   */
  bool clippingEnabled = false;
  
  /**
   * main Canvas 2D/3D Context of game engine
   *     CanvasRenderingContext
   *       |
   *       -- CanvasRenderingContext2D
   *       |
   *       -- WebGL.RenderingContext
   */
  Html.CanvasRenderingContext renderContext;

  // ----------------------------------------------------------
  // Constructors
  // ----------------------------------------------------------
  DrawContext();
  
  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  bool get isWebGLContext => renderContext is WebGL.RenderingContext;
  bool get isCanvasContext => renderContext is Html.CanvasRenderingContext2D;
  
  String get fillColor => _fillColor;
  String get drawColor => _drawColor;
  String _prevFillColor;
  String _prevDrawColor;
  
  set fillColor(String c) {
    if (c != null) {
      filled = true;
      _fillColor = c;
    }
    else {
      filled = false;
    }
  }

  set drawColor(String c) {
    if (c != null) {
      outlined = true;
      _drawColor = c;
    }
    else {
      outlined = false;
    }
  }

  void clear();
  
  void before();
  
  void after();
  
  /**
   * You should call [save] and [restore] inside any overridden draw___()
   * method. Failure to do so will certainly cause unexpected results.
   * For example, one of your [Node]s could have an outline drawn even
   * though you didn't explicitly supply a drawColor. This can happen
   * because another [Node] may have set the drawColor and failed to
   * call [save] and [restore]. So remember make sure each of your [Node]s
   * is properly saving and restoring state.
   */
  void save();
  
  /**
   * See [save] method for details.
   *  Make sure each of your [Node]s is properly saving and restoring state. 
   */
  void restore();

  void size(int width, int height);
  
  // Transforms
  void configureBaseTransform();
  void transform(BaseNode node);
  void transformWith(AffineTransform t);
  
  void clip();
  
  void set surfaceClearColor(Color4<int> color);
  
  // Mappings
  Vector2P mapWorldToView(double x, double y);

  /// [p] is in physical mouse coordinates.
  Vector2P mapViewToWorldWithPoint(Vector2 p);
  
  /// [x],[y] is in physical mouse coordinates.
  Vector2P mapViewToWorld(int x, int y);
  /// [x],[y] is in physical mouse coordinates.
  Vector2P mapViewToDesign(int x, int y);
  /// [x],[y] is in physical mouse coordinates.
  Vector2P mapViewToNode(BaseNode node, int x, int y);
  
  MutableRectangle<double> mapViewRectToWorld(MutableRectangle<double> rect);
  MutableRectangle<double> mapViewRectToNode(BaseNode node, MutableRectangle<double> rect);

  // ----------------------------------------------------------
  // Picking
  // ----------------------------------------------------------
  bool pointInside(Vector2 point);

  // ----------------------------------------------------------
  // Drawing
  // ----------------------------------------------------------
  /**
   * draws a point at coordinates.
   */
  void drawPointAt(double x, double y, [num size]) {
  }
  
  /**
   * draws a point given x and y coordinate measured in points
   *  [Point] point
   */
  void drawPoint(Vector2 point, [num size]) {
  }

  /**
   * draws an array of points.
   */
  void drawPoints(List<Vector2> points) {
  }

  /**
   * draws a line given the origin and destination point measured in points
   */
  void drawLine(Vector2 origin, Vector2 destination) {
  }

  void drawText(String text, Vector2 pos) {
    
  }
  
  void drawLineByComp(double x1, double y1, double x2, double y2) {
  }

  /**
   * draws a rectangle given the origin and destination point measured in points.
   */
  void drawRect(double left, double bottom, double width, double height) {
  }

  /**
   * draws a solid rectangle given the origin and destination point measured in points.
   */
  void drawSolidRect(Vector2 origin, Vector2 destination, Color4<double> color) {
  }

  /**
   * draws a poligon given a pointer to Point coordiantes and the number of vertices measured in points.
   * [vertices] Point coordiantes,
   * [closePolygon] The polygon can be closed or open,
   * [fill] The polygon can be closed or open and optionally filled with current color
   */
  void drawPoly(List<Vector2> vertices, bool closePolygon, bool solid) {
  }

  /**
   * draws a solid polygon given a pointer to CGPoint coordiantes, the number of vertices measured in points, and a color.
   */
  void drawSolidPoly(List<Vector2> vertices, Color4<double> color) {
  }

  /**
   * draws a circle given the center, radius and number of segments.
   *  [angle] angle in radians
   */
  void drawCircle(Vector2 center, double radius, double angle, int segments, bool drawLineToCenter) {
  }

  /**
   * draws a quad bezier path
   */
  void drawQuadBezier(Vector2 origin, Vector2 control, Vector2 destination, int segments) {
  }

  /**
   * draws a cubic bezier path
   */
  void drawCubicBezier(Vector2 origin, Vector2 control1, Vector2 control2, Point destination, int segments) {
  }

  /**
   * draw a catmull rom line
   */
  void drawCatmullRom(List<Vector2> points, int segments) {
  }

  /**
   * draw a cardinal spline path
   */
  void drawCardinalSpline(List<Vector2> config, double tension, int segments) {
  }
}

